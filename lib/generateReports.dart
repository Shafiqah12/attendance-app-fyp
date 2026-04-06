import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:provider/provider.dart';

import 'Theme/appTheme.dart';
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';

class GenerateReports extends StatefulWidget {
  const GenerateReports({super.key});
  @override
  _GenerateReportsPageState createState() => _GenerateReportsPageState();
}

class _GenerateReportsPageState extends State<GenerateReports> {
  List<Class> _classes = [];
  String? _selectedClassId;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  bool _generating = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
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

      final classes = await ApiService.getClasses(userId);
      setState(() {
        _classes = classes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load classes: $e';
        _loading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_selectedClassId == null ||
        _fromController.text.isEmpty ||
        _toController.text.isEmpty) return;
    
    setState(() => _generating = true);

    try {
      final from = DateTime.parse(_fromController.text);
      final to = DateTime.parse(_toController.text);

      // Get enrolled students and their attendance from API
      final enrolledStudents = await ApiService.getEnrolledStudents(_selectedClassId!);
      final attendanceData = await ApiService.getAttendanceForDateRange(
        _selectedClassId!,
        from,
        to,
      );

      // Get all dates in range
      final datesSet = <String>{};
      for (var att in attendanceData) {
        datesSet.add(att.date);
      }
      final dates = datesSet.toList()..sort();

      // Build Excel workbook
      final wb = xls.Workbook();
      final sheet = wb.worksheets[0];
      
      // Create header row
      final header = ['Registration Number', 'Student Name', ...dates];
      for (var c = 0; c < header.length; c++) {
        sheet.getRangeByIndex(1, c + 1).setText(header[c]);
      }

      // Fill data rows
      for (var i = 0; i < enrolledStudents.length; i++) {
        final student = enrolledStudents[i];
        
        // Registration number
        sheet.getRangeByIndex(i + 2, 1).setText(student.studentRegistrationNumber);
        
        // Student name
        sheet.getRangeByIndex(i + 2, 2).setText(student.studentName);
        
        // Attendance for each date
        for (var j = 0; j < dates.length; j++) {
          final date = dates[j];
          final status = _getAttendanceStatus(attendanceData, student.id, date);
          sheet.getRangeByIndex(i + 2, j + 3).setText(status);
        }
      }

      // Save to bytes
      final bytes = wb.saveAsStream();
      
      // Write to app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final fallbackPath = '${appDocDir.path}/attendance_report_$_selectedClassId.xlsx';
      final fallbackFile = File(fallbackPath);
      await fallbackFile.writeAsBytes(bytes, flush: true);
      
      String finalPath = fallbackPath;

      // Try to save to Downloads folder on Android
      if (Platform.isAndroid) {
        final perm = Platform.isAndroid && (await Permission.manageExternalStorage.isGranted)
            ? Permission.manageExternalStorage
            : Permission.storage;
        
        if (await perm.request().isGranted) {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final targetPath = '${downloadsDir.path}/attendance_report_$_selectedClassId.xlsx';
            final targetFile = File(targetPath);
            await targetFile.writeAsBytes(bytes, flush: true);
            finalPath = targetPath;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved to Downloads: $targetPath')),
              );
            }
          }
        }
      }

      // Open the file
      await OpenFile.open(finalPath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  String _getAttendanceStatus(List<AttendanceRecord> records, String studentId, String date) {
    final record = records.firstWhere(
      (r) => r.studentId == studentId && r.date == date,
      orElse: () => AttendanceRecord(studentId: '', date: '', status: ''),
    );
    return record.status.isEmpty ? '' : record.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final colors = theme.colorScheme;
    final btnStyle = theme.elevatedButtonTheme.style;

    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text('Generate Report', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
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
                          onPressed: _loadClasses,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Class Name:', style: textTh.headlineSmall?.copyWith(color: colors.primary)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedClassId,
                        hint: const Text('Select class'),
                        items: _classes
                            .map((e) => DropdownMenuItem(value: e.id, child: Text(e.courseName)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClassId = v),
                      ),
                      const SizedBox(height: 20),
                      Text('From Date (YYYY-MM-DD):', style: textTh.headlineSmall?.copyWith(color: colors.primary)),
                      TextField(
                        controller: _fromController,
                        decoration: const InputDecoration(hintText: '2025-01-13'),
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 20),
                      Text('To Date (YYYY-MM-DD):', style: textTh.headlineSmall?.copyWith(color: colors.primary)),
                      TextField(
                        controller: _toController,
                        decoration: const InputDecoration(hintText: '2025-01-20'),
                        keyboardType: TextInputType.datetime,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: btnStyle,
                        onPressed: _generating ? null : _generateReport,
                        child: _generating
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Generate Report', style: textTh.labelLarge),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}