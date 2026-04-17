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
  List<Student> _availableStudents = [];
  List<String> _selectedStudentIds = [];
  List<String> _enrolledStudentIds = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId != null && widget.classId != null) {
        final enrolled = await ApiService.getEnrolledStudents(widget.classId!);
        _enrolledStudentIds = enrolled.map((e) => e.id).toList();

        final allStudents = await ApiService.getAllStudents(userId);
        _availableStudents = allStudents
            .where((s) => !_enrolledStudentIds.contains(s.id))
            .toList();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    for (final studentId in _selectedStudentIds) {
      await ApiService.enrollStudent(widget.classId!, studentId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Students enrolled'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    }
  }

  void _toggleStudent(String id) {
    setState(() {
      if (_selectedStudentIds.contains(id)) {
        _selectedStudentIds.remove(id);
      } else {
        _selectedStudentIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Students')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableStudents.length,
                    itemBuilder: (context, index) {
                      final student = _availableStudents[index];
                      final isSelected = _selectedStudentIds.contains(student.id);
                      return CheckboxListTile(
                        title: Text(student.studentName),
                        subtitle: Text(student.studentRegistrationNumber),
                        value: isSelected,
                        onChanged: (_) => _toggleStudent(student.id),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _selectedStudentIds.isEmpty ? null : _save,
                    child: const Text('Enroll Selected'),
                  ),
                ),
              ],
            ),
    );
  }
}