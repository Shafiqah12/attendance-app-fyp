// editProfile.dart
import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/api_service.dart';
import 'Parts/Custom_buttons.dart';
import 'Theme/appTheme.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _firstController = TextEditingController();
  final _lastController  = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // Optional phone field
  bool _loading = true;
  bool _saving = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;
    final userEmail = authService.userEmail;
    final userName = authService.userName;
    
    if (userId == null) {
      // User not logged in, go back to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, appRoutes.loginPage);
      }
      return;
    }

    setState(() {
      _userId = userId;
    });

    try {
      // Try to get full profile from API
      final profile = await ApiService.getUserProfile(userId);
      
      if (profile != null) {
        _firstController.text = profile.firstName;
        _lastController.text = profile.lastName;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone ?? '';
      } else {
        // Use data from auth service
        final nameParts = (userName ?? 'User').split(' ');
        _firstController.text = nameParts.isNotEmpty ? nameParts[0] : '';
        _lastController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        _emailController.text = userEmail ?? '';
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Show error but still allow editing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_userId == null) return;

    setState(() => _saving = true);

    try {
      final profileData = {
        'firstName': _firstController.text.trim(),
        'lastName': _lastController.text.trim(),
        if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text.trim(),
      };

      final success = await ApiService.updateUserProfile(_userId!, profileData);
      
      if (success && mounted) {
        // Update local auth service if needed
        final authService = Provider.of<AuthService>(context, listen: false);
        // You might want to update the user name in auth service
        // This depends on how your AuthService is implemented
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
        
        Navigator.pushReplacementNamed(context, appRoutes.profilePage);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final btnTh = theme.elevatedButtonTheme.style;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // First name
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _firstController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z]")),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'John',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),

              // Last name
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _lastController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z]")),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Gates',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),

              // Phone (optional new field)
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _phoneController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                    hintText: '123-456-7890',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ),

              // Email (read-only)
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _emailController,
                  readOnly: true,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Email (cannot be changed)',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                  ),
                ),
              ),

              // Save button
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(
                  width: double.infinity, height: 48),
                child: ElevatedButton(
                  style: btnTh,
                  onPressed: _saving ? null : _saveChanges,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : Text(
                          "Save Changes",
                          style: theme.textTheme.labelLarge,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}