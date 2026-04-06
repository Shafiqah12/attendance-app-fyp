import 'package:attendify/Parts/Custom_listCardStudent.dart';
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';

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
        content: Text('Are you sure you want to delete $studentName?'),
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
      final success = await ApiService.deleteStudent(studentId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted $studentName')),
        );
        _loadStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete student'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final btnTh = theme.elevatedButtonTheme.style;

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Students', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Students: ${_students.length}",
                  style: textTh.headlineMedium,
                ),
                ElevatedButton(
                  style: btnTh,
                  onPressed: () {
                    Navigator.pushNamed(context, appRoutes.addStudentPage);
                  },
                  child: const Text("Add Student"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadStudents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _students.isEmpty
                        ? const Center(child: Text('No students found.'))
                        : RefreshIndicator(
                            onRefresh: _loadStudents,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              itemCount: _students.length,
                              itemBuilder: (context, i) {
                                final student = _students[i];
                                return listCardStudent(
                                  student: student,
                                  onEdit: () {
                                    Navigator.pushNamed(
                                      context,
                                      appRoutes.editStudentPage,
                                      arguments: {'studentId': student.id},
                                    );
                                  },
                                  onDelete: () => _deleteStudent(student.id, student.studentName),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}