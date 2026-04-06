import 'package:attendify/Parts/Custom_listCardMarkAttendance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/appTheme.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';

class MarkAttendanceView extends StatefulWidget {
  final String classId;
  const MarkAttendanceView({super.key, required this.classId});

  @override
  _MarkAttendanceViewState createState() => _MarkAttendanceViewState();
}

class _MarkAttendanceViewState extends State<MarkAttendanceView> {
  final Map<String, String> attendanceStatus = {};
  String _courseName = '';
  String dropdownValue = 'All Absent';
  bool _saving = false;
  bool _loading = true;
  List<EnrolledStudent> _students = [];
  String? _error;

  String get todayId => DateTime.now().toIso8601String().split('T').first;

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

      final attendanceExists = await ApiService.checkAttendanceExists(widget.classId, todayId);
      
      if (attendanceExists && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance already marked for today'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      final statusMap = <String, String>{};
      for (var student in students) {
        statusMap[student.id] = 'A';
      }
      
      setState(() {
        attendanceStatus.clear();
        attendanceStatus.addAll(statusMap);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _loading = false;
      });
    }
  }

  void _setAll(String status) {
    setState(() {
      for (var key in attendanceStatus.keys) {
        attendanceStatus[key] = status;
      }
      dropdownValue = status == 'P' ? 'All Present' : 'All Absent';
    });
  }

  Future<void> _saveAttendance() async {
    if (attendanceStatus.isEmpty) return;

    setState(() => _saving = true);

    try {
      final attendanceData = <Map<String, dynamic>>[];
      for (var entry in attendanceStatus.entries) {
        attendanceData.add({
          'studentId': entry.key,
          'status': entry.value,
          'date': todayId,
          'classId': widget.classId,
        });
      }

      final success = await ApiService.saveAttendance(widget.classId, todayId, attendanceData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save attendance'),
            backgroundColor: Colors.red,
          ),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Mark Attendance', style: theme.appBarTheme.titleTextStyle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subject:', style: textTh.headlineMedium),
                                Text(_courseName, style: textTh.headlineSmall),
                                const SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: dropdownValue,
                                  items: const [
                                    DropdownMenuItem(value: 'All Present', child: Text('All Present')),
                                    DropdownMenuItem(value: 'All Absent', child: Text('All Absent')),
                                  ],
                                  onChanged: (val) {
                                    if (val == 'All Present') _setAll('P');
                                    else if (val == 'All Absent') _setAll('A');
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: btnStyle,
                              onPressed: _saving ? null : _saveAttendance,
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text('Save', style: textTh.labelLarge),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _students.isEmpty
                            ? const Center(child: Text('No students enrolled.'))
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) {
                                    final student = _students[index];
                                    final status = attendanceStatus[student.id] ?? 'A';
                                    return listCardMarkAttendence(
                                      student: student,  // CHANGED: 'Student:' to 'student:'
                                      status: status,
                                      onToggle: () {
                                        setState(() {
                                          attendanceStatus[student.id] = status == 'A' ? 'P' : 'A';
                                        });
                                      },
                                      // REMOVED: 'student: null,' line
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}