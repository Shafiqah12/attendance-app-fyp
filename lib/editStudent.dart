import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';
import 'Theme/apptheme.dart';

class EditStudentPage extends StatefulWidget {
  final String? studentId;
  const EditStudentPage({super.key, this.studentId});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  late TextEditingController _nameController;
  late TextEditingController _regNumberController;
  late TextEditingController _classController;
  late TextEditingController _emailController;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _studentId;
  String? _originalEmail;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _regNumberController = TextEditingController();
    _classController = TextEditingController();
    _emailController = TextEditingController();
    if (widget.studentId != null) {
      _fetchStudent();
    }
  }

  Future<void> _fetchStudent() async {
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

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/students/${widget.studentId}'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _nameController.text = data['name'] ?? '';
        _regNumberController.text = data['reg_number'] ?? '';
        _classController.text = data['class_name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _originalEmail = data['email'];
        _studentId = widget.studentId;
      } else {
        setState(() {
          _error = 'Student not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load student: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_studentId == null) return;
    
    final newName = _nameController.text.trim();
    final newReg = _regNumberController.text.trim();
    final newEmail = _emailController.text.trim();
    
    if (newName.isEmpty || newReg.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!newEmail.contains('@') || !newEmail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final studentData = {
        'name': newName,
        'registrationNumber': newReg,
        'className': _classController.text.trim(),
        'email': newEmail,
      };

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/students/${_studentId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(studentData),
      ).timeout(const Duration(seconds: 10));
      
      final success = response.statusCode == 200;
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update student'),
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
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regNumberController.dispose();
    _classController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;
    final inputTh = theme.inputDecorationTheme;
    final btnTh = theme.elevatedButtonTheme.style;

    return SafeArea(
      child: Scaffold(
        endDrawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text('Edit Student', style: theme.appBarTheme.titleTextStyle),
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
                          onPressed: _fetchStudent,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                            FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\s]")),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Student Name *',
                            hintText: 'Full name of student',
                            prefixIcon: Icon(Icons.person, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _regNumberController,
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
                        TextField(
                          controller: _emailController,
                          style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                            FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9._%+-@]")),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Student Email *',
                            hintText: 'student@email.com',
                            prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _classController,
                          decoration: InputDecoration(
                            labelText: 'Class (optional)',
                            hintText: 'Computer Science',
                            prefixIcon: Icon(Icons.class_, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                        ),
                        const SizedBox(height: 30),
                        ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(height: 48),
                          child: ElevatedButton(
                            style: btnTh,
                            onPressed: _saving ? null : _saveChanges,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text('Save Changes', style: textTh.labelLarge),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '* Required fields',
                          style: textTh.bodySmall?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}