import 'package:attendify/Parts/Custom_listCardMarkAttendance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/appTheme.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';

class EditAttendanceView extends StatefulWidget {
  final String classId;
  final String attendanceDate;
  const EditAttendanceView({
    super.key, 
    required this.classId, 
    required this.attendanceDate
  });

  @override
  _EditAttendancePageState createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendanceView> {
  final Map<String, String> _attendanceStatus = {};
  String _courseName = '';
  bool _loading = true;
  bool _saving = false;
  List<EnrolledStudent> _students = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        setState(() {
          _error = 'User not logged in';
          _loading = false;
        });
        return;
      }

      final className = await ApiService.getClassName(widget.classId);
      _courseName = className;

      final students = await ApiService.getEnrolledStudents(widget.classId);
      _students = students;

      final statusMap = <String, String>{};
      for (var student in students) {
        final status = await ApiService.getAttendanceStatus(
          widget.classId, 
          student.id, 
          widget.attendanceDate
        );
        statusMap[student.id] = status;
      }
      
      setState(() {
        _attendanceStatus.clear();
        _attendanceStatus.addAll(statusMap);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final attendanceData = <Map<String, dynamic>>[];
      for (var entry in _attendanceStatus.entries) {
        attendanceData.add({
          'studentId': entry.key,
          'status': entry.value,
          'date': widget.attendanceDate,
          'classId': widget.classId,
        });
      }

      final success = await ApiService.saveAttendance(widget.classId, widget.attendanceDate, attendanceData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance updated successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update attendance'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final btnStyle = theme.elevatedButtonTheme.style;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Edit Attendance', style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saving ? null : _save,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject:', style: textTh.headlineMedium),
                      Text(_courseName, style: textTh.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Date: ${widget.attendanceDate}', style: textTh.bodyMedium),
                    ],
                  ),
                  ElevatedButton(
                    style: btnStyle,
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Save', style: textTh.labelLarge),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text('No students enrolled.'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final currentStatus = _attendanceStatus[student.id] ?? 'A';
                        return listCardMarkAttendance(
                          student: student,  // ONLY keep this one (lowercase)
                          status: currentStatus,
                          onToggle: () {
                            setState(() {
                              _attendanceStatus[student.id] = currentStatus == 'A' ? 'P' : 'A';
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  listCardMarkAttendance({required EnrolledStudent student, required String status, required Null Function() onToggle}) {}
}