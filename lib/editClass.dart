// editClass.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Theme/apptheme.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';

class EditClassPage extends StatefulWidget {
  final String classId;
  const EditClassPage({super.key, required this.classId});

  @override
  _EditClassPageState createState() => _EditClassPageState();
}

class _EditClassPageState extends State<EditClassPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  Future<void> _loadClassData() async {
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

      // Fetch class details from API
      final classData = await ApiService.getClassById(widget.classId);
      
      if (classData != null) {
        _nameController.text = classData.courseName;
        _startController.text = classData.startingDate;
        _endController.text = classData.endingDate;
      } else {
        setState(() {
          _error = 'Class not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load class: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();
    final newStart = _startController.text.trim();
    final newEnd = _endController.text.trim();
    
    if (newName.isEmpty || newStart.isEmpty || newEnd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final classData = {
        'courseName': newName,
        'startingDate': newStart,
        'endingDate': newEnd,
      };

      final success = await ApiService.updateClass(widget.classId, classData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update class'),
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

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      // Format date as DD-MM-YYYY
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";
      controller.text = formattedDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
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
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text('Edit Class', style: theme.appBarTheme.titleTextStyle),
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
                          onPressed: _loadClassData,
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
                        // Class Name
                        TextField(
                          controller: _nameController,
                          style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                            FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9 ]")),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Class Name *',
                            hintText: 'Software Engineering',
                            prefixIcon: Icon(Icons.class_, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                        ),
                        const SizedBox(height: 20),
                        
                        // Start Date (with date picker)
                        TextFormField(
                          controller: _startController,
                          style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          readOnly: true,
                          onTap: () => _selectDate(_startController),
                          decoration: InputDecoration(
                            labelText: 'Start Date *',
                            hintText: '21-03-2025',
                            prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                        ),
                        const SizedBox(height: 20),
                        
                        // End Date (with date picker)
                        TextFormField(
                          controller: _endController,
                          style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          readOnly: true,
                          onTap: () => _selectDate(_endController),
                          decoration: InputDecoration(
                            labelText: 'End Date *',
                            hintText: '21-07-2025',
                            prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                            suffixIcon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                          ).applyDefaults(inputTh),
                        ),
                        const SizedBox(height: 30),
                        
                        // Save Button
                        ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(width: double.infinity, height: 48),
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