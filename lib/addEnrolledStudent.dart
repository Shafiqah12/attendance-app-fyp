import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';

class AddEnrolledStudent extends StatefulWidget {
  final String? classId;
  const AddEnrolledStudent({super.key, this.classId});

  @override
  State<AddEnrolledStudent> createState() => _AddEnrolledStudentState();
}

class _AddEnrolledStudentState extends State<AddEnrolledStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Student'),
      ),
      body: const Center(
        child: Text('Add Enrolled Student Page - Coming Soon'),
      ),
    );
  }
}