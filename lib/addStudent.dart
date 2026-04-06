// addStudent.dart
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Theme/apptheme.dart';
import 'Parts/custom_widgets.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _nameCtrl = TextEditingController();
  final _regCtrl  = TextEditingController();
  final _classCtrl = TextEditingController(); // Optional: add class field
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regCtrl.dispose();
    _classCtrl.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    // Validate inputs
    final name = _nameCtrl.text.trim();
    final reg  = _regCtrl.text.trim();
    
    if (name.isEmpty || reg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        // User not logged in, go back to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, appRoutes.loginPage);
        }
        return;
      }

      // Prepare student data
      final studentData = {
        'name': name,
        'registrationNumber': reg,
        'ownerUid': userId,
        'class': _classCtrl.text.trim().isEmpty ? null : _classCtrl.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Call API to add student
      final success = await ApiService.addStudent(studentData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add student'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final textTh  = theme.textTheme;
    final inputTh = theme.inputDecorationTheme;
    final btnTh   = theme.elevatedButtonTheme.style;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text('Add Student', style: theme.appBarTheme.titleTextStyle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Student Name
                TextField(
                  controller: _nameCtrl,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\s]")),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Student Name *',
                    hintText: 'Hassan Mahsam',
                    prefixIcon: Icon(Icons.school, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 20),
                
                // Registration Number
                TextField(
                  controller: _regCtrl,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9\-]")),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Registration Number *',
                    hintText: '22-CS-404',
                    prefixIcon: Icon(Icons.confirmation_number, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 20),
                
                // Class (optional)
                TextField(
                  controller: _classCtrl,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Class (optional)',
                    hintText: 'Computer Science',
                    prefixIcon: Icon(Icons.class_, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 30),
                
                // Add Button
                ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: double.infinity, height: 48),
                  child: ElevatedButton(
                    style: btnTh,
                    onPressed: _isSubmitting ? null : _addStudent,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text("Add New Student"),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Required fields note
                Text(
                  '* Required fields',
                  style: textTh.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}