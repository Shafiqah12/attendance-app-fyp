import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrolled Students'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _enrolledStudents.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No students enrolled'),
                          SizedBox(height: 8),
                          Text('Tap button below to enroll students'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _enrolledStudents.length,
                      itemBuilder: (context, index) {
                        final student = _enrolledStudents[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(student.studentName),
                            subtitle: Text(student.studentRegistrationNumber),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final success = await ApiService.unenrollStudent(student.enrollmentId);
                                if (success) {
                                  _loadEnrolledStudents();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Student removed'), backgroundColor: Colors.green),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            appRoutes.addEnrolledStudentPage,
            arguments: widget.classId,
          ).then((_) => _loadEnrolledStudents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}