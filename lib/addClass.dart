// addClass.dart
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Theme/apptheme.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate inputs
    final name = _nameController.text.trim();
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    
    if (name.isEmpty || start.isEmpty || end.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
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

      // Prepare class data
      final classData = {
        'courseName': name,
        'startingDate': start,
        'endingDate': end,
        'ownerUid': userId,
      };

      // Call API to add class
      final success = await ApiService.addClass(classData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add class'),
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

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      // Format date as DD-MM-YYYY to match your hint text
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";
      controller.text = formattedDate;
    }
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
          title: Text('Add Class', style: theme.appBarTheme.titleTextStyle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Class Name Field
                TextField(
                  controller: _nameController,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9 ]")),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    hintText: 'Software Engineering',
                    prefixIcon: Icon(Icons.class_, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 20),

                // Start Date Field (with date picker)
                TextFormField(
                  controller: _startController,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  readOnly: true, // Make it read-only to force date picker
                  onTap: () => _selectDate(_startController),
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    hintText: '21-03-2025',
                    prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 20),

                // End Date Field (with date picker)
                TextFormField(
                  controller: _endController,
                  style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  readOnly: true, // Make it read-only to force date picker
                  onTap: () => _selectDate(_endController),
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    hintText: '21-07-2025',
                    prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                  ).applyDefaults(inputTh),
                ),
                const SizedBox(height: 30),

                // Submit Button
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: double.infinity, height: 48),
                  child: ElevatedButton(
                    style: btnTh,
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Add New Class'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}