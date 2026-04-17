import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    final latText = _latitudeController.text.trim();
    final lngText = _longitudeController.text.trim();
    
    if (name.isEmpty || start.isEmpty || end.isEmpty) {
      _showSnackBar('Please fill all required fields', Colors.red);
      return;
    }

    double? latitude;
    double? longitude;
    
    if (latText.isNotEmpty && lngText.isNotEmpty) {
      latitude = double.tryParse(latText);
      longitude = double.tryParse(lngText);
      if (latitude == null || longitude == null) {
        _showSnackBar('Invalid coordinates. Use format like 5.4085', Colors.red);
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final classData = {
        'courseName': name,
        'startingDate': start,
        'endingDate': end,
        'ownerUid': userId,
        'latitude': latitude,
        'longitude': longitude,
      };

      final success = await ApiService.addClass(classData);
      
      if (success && mounted) {
        _showSnackBar('Class added successfully', Colors.green);
        Navigator.pop(context, true);
      } else if (mounted) {
        _showSnackBar('Failed to add class', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
      appBar: AppBar(title: const Text('Add Class')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Class Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Start Date (DD-MM-YYYY) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'End Date (DD-MM-YYYY) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    '📍 Classroom Location (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan koordinat dari Google Maps untuk GPS verification',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 5.4085',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 103.0862',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSubmitting 
                  ? const CircularProgressIndicator() 
                  : const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }
}