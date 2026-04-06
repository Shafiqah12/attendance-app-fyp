// viewAttendanceView.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/appTheme.dart';
import 'Parts/Custom_listCardViewAttendance.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';

// REMOVED local AttendanceRecordForView - using from api_service.dart

class ViewAttendanceView extends StatefulWidget {
  final String classId;
  final String attendanceDate;
  const ViewAttendanceView({
    super.key, 
    required this.classId, 
    required this.attendanceDate
  });

  @override
  _ViewAttendanceViewState createState() => _ViewAttendanceViewState();
}

class _ViewAttendanceViewState extends State<ViewAttendanceView> {
  List<AttendanceRecordForView> _attendanceList = [];
  String _courseName = '';
  bool _loading = true;
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

      // Load class name
      final className = await ApiService.getClassName(widget.classId);
      _courseName = className;

      // Load attendance for this date
      final attendanceData = await ApiService.getAttendanceForDate(
        widget.classId, 
        widget.attendanceDate
      );
      
      setState(() {
        _attendanceList = attendanceData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load attendance data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('View Attendance - ${widget.attendanceDate}',
            style: theme.appBarTheme.titleTextStyle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Subject: $_courseName',
                    style: textTh.headlineMedium),
                Text('Date: ${widget.attendanceDate}', style: textTh.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
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
                    : _attendanceList.isEmpty
                        ? const Center(child: Text('No records found.'))
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, 
                                vertical: 20
                              ),
                              itemCount: _attendanceList.length,
                              itemBuilder: (context, index) {
                                final item = _attendanceList[index];
                                return listCardViewAttendence(
                                  studentName: item.studentName,
                                  studentRegistration: item.studentRegistrationNumber,
                                  status: item.status,
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