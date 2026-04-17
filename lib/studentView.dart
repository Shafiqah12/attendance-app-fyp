import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';

class StudentViewPage extends StatefulWidget {
  const StudentViewPage({super.key});

  @override
  State<StudentViewPage> createState() => _StudentViewPageState();
}

class _StudentViewPageState extends State<StudentViewPage> {
  List<Student> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getStudents(userId);
      
      setState(() {
        _students = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load students: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStudent(String studentId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Delete "$studentName"?'),
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
      final success = await ApiService.deleteStudent(studentId);
      if (success) {
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLecturer = authService.userRole == 'lecturer' || authService.userRole == 'admin';
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final btnTh = theme.elevatedButtonTheme.style;

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Students', style: theme.appBarTheme.titleTextStyle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _students.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No students'),
                          SizedBox(height: 8),
                          Text('Tap + to add a student'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStudents,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(student.studentName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.studentRegistrationNumber),
                                  if (student.className != null && student.className!.isNotEmpty)
                                    Text('Class: ${student.className}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: isLecturer
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Edit Button
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              appRoutes.editStudentPage,
                                              arguments: {'studentId': student.id},
                                            ).then((_) => _loadStudents());
                                          },
                                          tooltip: 'Edit Student',
                                        ),
                                        // Delete Button
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteStudent(student.id, student.studentName),
                                          tooltip: 'Delete Student',
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: isLecturer
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, appRoutes.addStudentPage).then((_) => _loadStudents());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}