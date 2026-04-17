import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';

class MarkAttendanceView extends StatefulWidget {
  final String classId;
  const MarkAttendanceView({super.key, required this.classId});

  @override
  State<MarkAttendanceView> createState() => _MarkAttendanceViewState();
}

class _MarkAttendanceViewState extends State<MarkAttendanceView> {
  final Map<String, String> attendanceStatus = {};
  String _courseName = '';
  bool _loading = true;
  bool _saving = false;
  List<EnrolledStudent> _students = [];
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

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      // Load class location
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

  Future<void> _saveAttendance() async {
    setState(() {
      _saving = true;
      _distanceMessage = '📍 Checking location...';
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _saving = false);
        _showSnackBar('Location permission required', Colors.red);
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Check if class has location set
      if (!_hasLocation) {
        setState(() => _saving = false);
        _showSnackBar('Classroom location not set. Please contact lecturer.', Colors.orange);
        return;
      }
      
      // Calculate distance
      double distance = Geolocator.distanceBetween(
        _classroomLat, _classroomLng,
        position.latitude, position.longitude
      );
      
      setState(() {
        _distanceMessage = '📍 Distance: ${distance.toStringAsFixed(1)} meters';
      });

      if (distance > 5) {
        setState(() => _saving = false);
        _showSnackBar('❌ You are ${distance.toStringAsFixed(1)}m away. Must be within 5m!', Colors.red);
        return;
      }

      // Save attendance
      final attendanceData = attendanceStatus.entries.map((e) => ({
        'studentId': e.key,
        'status': e.value,
        'date': todayId,
        'classId': widget.classId,
      })).toList();

      final success = await ApiService.saveAttendance(widget.classId, todayId, attendanceData);
      
      if (success && mounted) {
        _showSnackBar('✅ Attendance saved!', Colors.green);
        Navigator.pop(context, true);
      } else if (mounted) {
        _showSnackBar('❌ Failed to save', Colors.red);
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Location banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _distanceMessage.contains('Distance') 
                        ? Colors.green.shade50 
                        : (_hasLocation ? Colors.blue.shade50 : Colors.orange.shade50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _distanceMessage.contains('Distance') 
                            ? Icons.check_circle 
                            : (_hasLocation ? Icons.location_on : Icons.warning),
                        color: _distanceMessage.contains('Distance') 
                            ? Colors.green 
                            : (_hasLocation ? Colors.blue : Colors.orange),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _distanceMessage.isEmpty 
                              ? (_hasLocation 
                                  ? '📍 Location will be checked when you save' 
                                  : '⚠️ No location set for this class. Contact lecturer.')
                              : _distanceMessage,
                          style: TextStyle(
                            color: _distanceMessage.contains('Distance') 
                                ? Colors.green.shade700 
                                : (_hasLocation ? Colors.blue.shade700 : Colors.orange.shade700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Subject name
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Subject: $_courseName',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Student list
                Expanded(
                  child: _students.isEmpty
                      ? const Center(child: Text('No students enrolled'))
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final s = _students[index];
                            final status = attendanceStatus[s.id] ?? 'A';
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text(s.studentName),
                                subtitle: Text(s.studentRegistrationNumber),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('P'),
                                      selected: status == 'P',
                                      onSelected: (_) {
                                        setState(() {
                                          attendanceStatus[s.id] = 'P';
                                        });
                                      },
                                      selectedColor: Colors.green,
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text('A'),
                                      selected: status == 'A',
                                      onSelected: (_) {
                                        setState(() {
                                          attendanceStatus[s.id] = 'A';
                                        });
                                      },
                                      selectedColor: Colors.red,
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Save button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _saving || !_hasLocation ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _saving 
                        ? const CircularProgressIndicator() 
                        : const Text('Save Attendance'),
                  ),
                ),
              ],
            ),
    );
  }
}