import 'package:attendify/Parts/Custom_listCardMarkAttendance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/appTheme.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendify/services/nfc_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String _distanceMessage = '';
  double _classroomLat = 0.0;
  double _classroomLng = 0.0;
  bool _hasLocation = false;

  String get todayId => DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final location = await ApiService.getClassLocation(widget.classId);
      if (location != null) {
        _classroomLat = (location['latitude'] ?? 0.0).toDouble();
        _classroomLng = (location['longitude'] ?? 0.0).toDouble();
        _hasLocation = _classroomLat != 0.0 && _classroomLng != 0.0;
        if (_hasLocation) {
          print('📍 Classroom location: $_classroomLat, $_classroomLng');
        }
      }
      
      final className = await ApiService.getClassName(widget.classId);
      final students = await ApiService.getEnrolledStudents(widget.classId);
      
      setState(() {
        _courseName = className;
        _students = students;
        for (var s in students) {
          attendanceStatus[s.id] = 'A';
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission is required', Colors.orange);
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permission permanently denied', Colors.red);
      return false;
    }
    
    return true;
  }

  Future<bool> _isWithinClassroom() async {
    if (!_hasLocation) {
      setState(() {
        _distanceMessage = '⚠️ No location set for this class. Contact lecturer.';
      });
      print('❌ No classroom location available');
      return false;
    }
    
    try {
      print('📍 Getting current position...');
      
      // Add timeout to prevent infinite loading
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));
      
      print('📍 Your location: ${position.latitude}, ${position.longitude}');
      print('📍 Classroom: $_classroomLat, $_classroomLng');
      
      double distance = Geolocator.distanceBetween(
        _classroomLat, _classroomLng,
        position.latitude, position.longitude
      );
      
      setState(() {
        _distanceMessage = '📍 Distance: ${distance.toStringAsFixed(1)} meters';
      });
      
      print('📏 Calculated distance: ${distance.toStringAsFixed(1)} meters');
      print('🎯 Within 5 meters? ${distance <= 5.0}');
      
      return distance <= 5.0;
      
    } catch (e) {
      print('❌ Location error: $e');
      setState(() {
        _distanceMessage = '⚠️ Unable to get location. Please enable GPS.';
      });
      _showSnackBar('Unable to get location. Please enable GPS.', Colors.orange);
      return false;
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

    setState(() {
      _saving = true;
      _distanceMessage = '🔍 Checking location...';
    });

    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      setState(() => _saving = false);
      return;
    }
    
    bool isWithinRange = await _isWithinClassroom();
    
    if (!isWithinRange) {
      setState(() => _saving = false);
      _showSnackBar('❌ You must be within 5 meters of the classroom!', Colors.red);
      return;
    }

    try {
      final attendanceData = attendanceStatus.entries.map((e) => ({
        'studentId': e.key,
        'status': e.value,
        'date': todayId,
        'classId': widget.classId,
      })).toList();

      final success = await ApiService.saveAttendance(widget.classId, todayId, attendanceData);
      
      if (success && mounted) {
        _showSnackBar('✅ Attendance saved successfully!', Colors.green);
        Navigator.pop(context, true);
      } else if (mounted) {
        _showSnackBar('❌ Failed to save attendance', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _markWithNFC() async {
    if (_saving) return;
    
    setState(() => _saving = true);
    
    try {
      // ==========================================
      // STEP 1: CHECK LOCATION PERMISSION FIRST
      // ==========================================
      print('🔍 Step 1: Checking location permission...');
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied');
        setState(() => _saving = false);
        return;
      }
      print('✅ Location permission granted');
      
      // ==========================================
      // STEP 2: CHECK DISTANCE FIRST (BEFORE READING NFC)
      // ==========================================
      setState(() {
        _distanceMessage = '🔍 Checking distance to classroom...';
      });
      
      print('🔍 Step 2: Checking distance to classroom...');
      bool isWithinRange = await _isWithinClassroom();
      
      if (!isWithinRange) {
        print('❌ Too far from classroom! NFC rejected.');
        setState(() => _saving = false);
        
        // Show clear error message with distance
        _showSnackBar(
          '❌ You must be within 5 meters of the classroom!\n$_distanceMessage', 
          Colors.red
        );
        return;
      }
      
      print('✅ Within 5 meter range! Proceeding to NFC...');
      
      // ==========================================
      // STEP 3: ONLY THEN READ NFC TAG
      // ==========================================
      setState(() {
        _distanceMessage = '✅ Within range! Please tap your NFC card...';
      });
      
      print('🔍 Step 3: Waiting for NFC tap...');
      final nfcId = await NFCService.readNfcTag(context);
      
      if (nfcId == null || nfcId.isEmpty) {
        print('❌ Failed to read NFC tag');
        _showSnackBar('❌ Failed to read NFC tag. Please try again.', Colors.red);
        setState(() => _saving = false);
        return;
      }
      
      print('✅ NFC tag read successfully: $nfcId');
      
      // ==========================================
      // STEP 4: VERIFY NFC CARD WITH BACKEND
      // ==========================================
      setState(() {
        _distanceMessage = '🔍 Verifying NFC card...';
      });
      
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/students/by-nfc?nfcId=$nfcId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final studentId = data['id'].toString();
        final studentName = data['name'];
        final authService = Provider.of<AuthService>(context, listen: false);
        final currentUserId = authService.userId;
        
        print('✅ NFC card belongs to: $studentName (ID: $studentId)');
        print('👤 Current user ID: $currentUserId');
        
        // Check if NFC card belongs to current user
        if (studentId == currentUserId) {
          print('✅ Card matches current user. Marking attendance...');
          
          setState(() {
            attendanceStatus[studentId] = 'P';
          });
          
          _showSnackBar('✅ $studentName marked present via NFC!', Colors.green);
          
          // Auto save attendance
          await _saveAttendance();
        } else {
          print('❌ Card belongs to different user!');
          _showSnackBar('❌ This NFC card is not registered to you', Colors.red);
        }
      } else {
        print('❌ NFC card not found in system');
        _showSnackBar('❌ NFC card not registered. Please contact administrator.', Colors.red);
      }
    } catch (e) {
      print('❌ NFC Error: $e');
      _showSnackBar('Error: $e', Colors.red);
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
    
    final authService = Provider.of<AuthService>(context);
    final isLecturer = authService.userRole == 'lecturer' || authService.userRole == 'admin';
    final currentUserId = authService.userId;

    List<EnrolledStudent> displayStudents = [];
    if (!isLecturer && currentUserId != null) {
      final currentStudent = _students.where((s) => s.id == currentUserId).toList();
      displayStudents = currentStudent;
    } else {
      displayStudents = _students;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          isLecturer ? 'Mark Attendance' : 'My Attendance',
          style: theme.appBarTheme.titleTextStyle,
        ),
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
              : Column(
                  children: [
                    // Location Banner with dynamic colors based on status
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _distanceMessage.contains('✅') 
                            ? Colors.green.shade50 
                            : (_distanceMessage.contains('❌') 
                                ? Colors.red.shade50
                                : (_hasLocation ? Colors.blue.shade50 : Colors.orange.shade50)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _distanceMessage.contains('✅') 
                              ? Colors.green 
                              : (_distanceMessage.contains('❌')
                                  ? Colors.red
                                  : (_hasLocation ? Colors.blue : Colors.orange)),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _distanceMessage.contains('✅') 
                                ? Icons.check_circle 
                                : (_distanceMessage.contains('❌')
                                    ? Icons.error
                                    : (_hasLocation ? Icons.location_on : Icons.warning)),
                            color: _distanceMessage.contains('✅') 
                                ? Colors.green 
                                : (_distanceMessage.contains('❌')
                                    ? Colors.red
                                    : (_hasLocation ? Colors.blue : Colors.orange)),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _distanceMessage.isEmpty 
                                  ? (_hasLocation 
                                      ? '📍 Location will be checked when you tap NFC' 
                                      : '⚠️ No location set for this class')
                                  : _distanceMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _distanceMessage.contains('❌') ? FontWeight.bold : FontWeight.normal,
                                color: _distanceMessage.contains('✅') 
                                    ? Colors.green.shade700 
                                    : (_distanceMessage.contains('❌')
                                        ? Colors.red.shade700
                                        : (_hasLocation ? Colors.blue.shade700 : Colors.orange.shade700)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Subject and Buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Subject:', style: textTh.headlineMedium),
                                Text(_courseName, style: textTh.headlineSmall),
                                const SizedBox(height: 8),
                                if (isLecturer)
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
                          ),
                          Column(
                            children: [
                              // NFC Button
                              SizedBox(
                                width: 90,
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: _saving ? null : _markWithNFC,
                                  icon: const Icon(Icons.nfc, size: 18),
                                  label: const Text('NFC'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Save Button (only for lecturer)
                              if (isLecturer)
                                SizedBox(
                                  width: 90,
                                  height: 45,
                                  child: ElevatedButton(
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
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Student List
                    Expanded(
                      child: displayStudents.isEmpty
                          ? Center(
                              child: Text(
                                isLecturer ? 'No students enrolled.' : 'You are not enrolled in this class.',
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                itemCount: displayStudents.length,
                                itemBuilder: (context, index) {
                                  final student = displayStudents[index];
                                  final status = attendanceStatus[student.id] ?? 'A';
                                  return listCardMarkAttendence(
                                    student: student,
                                    status: status,
                                    onToggle: () {
                                      if (isLecturer) {
                                        setState(() {
                                          attendanceStatus[student.id] = status == 'A' ? 'P' : 'A';
                                        });
                                      }
                                    },
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