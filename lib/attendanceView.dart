// attendanceView.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/apptheme.dart';
import 'package:attendify/util/appRoutes.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'Parts/Custom_listCardAttendance.dart';

class AttendanceViewPage extends StatefulWidget {
  final String classId;
  const AttendanceViewPage({super.key, required this.classId});

  @override
  _AttendanceViewPageState createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  List<String> _dates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAllDates();
  }

  Future<void> _fetchAllDates() async {
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

      // Get all attendance records for this class
      final attendanceRecords = await ApiService.getAttendanceDates(widget.classId);
      
      // Extract unique dates and sort descending (newest first)
      final dates = attendanceRecords.map((r) => r.date).toSet().toList();
      dates.sort((a, b) => b.compareTo(a));
      
      setState(() {
        _dates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load attendance records: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAttendance(String date) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: Text('Are you sure you want to delete attendance for $date?'),
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

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.deleteAttendanceByDate(widget.classId, date);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance for $date deleted')),
        );
        await _fetchAllDates(); // Refresh the list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete attendance'), backgroundColor: Colors.red),
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final btnTh = theme.elevatedButtonTheme.style;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text('Attendance', style: theme.appBarTheme.titleTextStyle),
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
                    Text('Total Attendances: ${_dates.length}', style: textTh.headlineSmall),
                    ElevatedButton(
                      style: btnTh,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          appRoutes.markAttendance,
                          arguments: widget.classId,
                        ).then((_) => _fetchAllDates());
                      },
                      child: const Text('Mark Attendance'),
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
                                  onPressed: _fetchAllDates,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _dates.isEmpty
                            ? const Center(child: Text('No attendance records.'))
                            : RefreshIndicator(
                                onRefresh: _fetchAllDates,
                                child: ListView.builder(
                                  itemCount: _dates.length,
                                  itemBuilder: (context, index) {
                                    final date = _dates[index];
                                    return listCardAttendance(
                                      attendance: Attendance(
                                        attendanceDate: date,
                                        presentStudents: '', // compute present count if desired
                                      ),
                                      classId: widget.classId,
                                      onDelete: () => _deleteAttendance(date),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}