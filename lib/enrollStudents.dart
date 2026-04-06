import 'package:attendify/Parts/Custom_listCardEnrolledStudent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Theme/apptheme.dart';
import 'package:attendify/util/appRoutes.dart';

class EnrollStudentsPage extends StatefulWidget {
  final String classId;
  const EnrollStudentsPage({super.key, required this.classId});

  @override
  State<EnrollStudentsPage> createState() => _EnrollStudentsPageState();
}

class _EnrollStudentsPageState extends State<EnrollStudentsPage> {
  List<EnrolledStudent> _enrolledStudents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  Future<void> _loadEnrolledStudents() async {
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

      final students = await ApiService.getEnrolledStudents(widget.classId);
      
      setState(() {
        _enrolledStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load enrolled students: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _unenrollStudent(String enrollmentId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unenroll Student'),
        content: Text('Are you sure you want to remove $studentName from this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await ApiService.unenrollStudent(enrollmentId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$studentName removed from class')),
        );
        _loadEnrolledStudents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove student'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Enrolled Students', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Students: ${_enrolledStudents.length}',
                  style: textTh.headlineMedium,
                ),
                ElevatedButton(
                  style: btnTh,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.addEnrolledStudentPage,
                      arguments: widget.classId,
                    ).then((_) => _loadEnrolledStudents());
                  },
                  child: const Text('Enroll Student'),
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
                              onPressed: _loadEnrolledStudents,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _enrolledStudents.isEmpty
                        ? const Center(child: Text('No students enrolled.'))
                        : RefreshIndicator(
                            onRefresh: _loadEnrolledStudents,
                            child: ListView.builder(
                              itemCount: _enrolledStudents.length,
                              itemBuilder: (context, index) {
                                final student = _enrolledStudents[index];
                                return listCardEnrolledStudent(
                                  classId: widget.classId,
                                  student: student,  // Directly pass EnrolledStudent
                                  onUnenroll: () => _unenrollStudent(
                                    student.enrollmentId,
                                    student.studentName,
                                  ),
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