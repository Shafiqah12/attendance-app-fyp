import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/util/appRoutes.dart';

class AttendanceViewPage extends StatefulWidget {
  final String classId;
  const AttendanceViewPage({super.key, required this.classId});

  @override
  State<AttendanceViewPage> createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  List<String> _dates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttendanceDates();
  }

  Future<void> _loadAttendanceDates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await ApiService.getAttendanceDates(widget.classId);
      final dates = records.map((r) => r.date).toSet().toList();
      dates.sort((a, b) => b.compareTo(a));
      
      setState(() {
        _dates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load attendance: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _dates.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No attendance records'),
                          SizedBox(height: 8),
                          Text('Tap "Mark Attendance" to create one'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final date = _dates[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('Date: $date'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      appRoutes.viewAttendanceViewPage,
                                      arguments: {
                                        'classId': widget.classId,
                                        'Date': date,
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      appRoutes.editAttendanceViewPage,
                                      arguments: {
                                        'classId': widget.classId,
                                        'Date': date,
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            appRoutes.markAttendance,
            arguments: widget.classId,
          ).then((_) => _loadAttendanceDates());
        },
        child: const Icon(Icons.add),
        tooltip: 'Mark Attendance',
      ),
    );
  }
}