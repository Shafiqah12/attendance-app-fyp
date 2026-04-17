import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';

class ClassesViewPage extends StatefulWidget {
  const ClassesViewPage({super.key});

  @override
  State<ClassesViewPage> createState() => _ClassesViewPageState();
}

class _ClassesViewPageState extends State<ClassesViewPage> {
  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;
    
    if (userId != null) {
      final classes = await ApiService.getClasses(userId);
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClass(String classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete "$className"?'),
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
    
    if (confirm == true) {
      final success = await ApiService.deleteClass(classId);
      if (success) {
        _loadClasses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class deleted'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLecturer = authService.userRole == 'lecturer' || authService.userRole == 'admin';

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Classes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No classes'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final c = _classes[index];
                    final hasLocation = (c['latitude'] != null && c['longitude'] != null);
                    final className = c['class_name'] ?? c['courseName'] ?? 'Unknown';
                    final classId = c['id'].toString();
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(className),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start: ${c['starting_date'] ?? c['startingDate'] ?? ''}'),
                            Text('End: ${c['ending_date'] ?? c['endingDate'] ?? ''}'),
                            if (hasLocation)
                              const Text('📍 GPS enabled', style: TextStyle(color: Colors.green, fontSize: 10)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Enroll Button
                            IconButton(
                              icon: const Icon(Icons.people, color: Colors.blue),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  appRoutes.enrollStudentPage,
                                  arguments: classId,
                                );
                              },
                              tooltip: 'Enroll Students',
                            ),
                            // Attendance Button
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  appRoutes.attendancePage,
                                  arguments: classId,
                                );
                              },
                              tooltip: 'Mark Attendance',
                            ),
                            // Edit Button (Lecturer only)
                            if (isLecturer)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    appRoutes.editClassPage,
                                    arguments: classId,
                                  );
                                },
                                tooltip: 'Edit Class',
                              ),
                            // Delete Button (Lecturer only)
                            if (isLecturer)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteClass(classId, className),
                                tooltip: 'Delete Class',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: isLecturer
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, appRoutes.addClassPage);
                _loadClasses();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}