import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Theme/apptheme.dart';             
import 'package:attendify/util/appRoutes.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart'; // Add this import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login function using your API
  Future<void> _loginWithApi() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      final userData = await ApiService.login(
        _emailController.text.trim(), 
        _passwordController.text,
      );
      
      if (userData != null && userData['success'] == true) {
        print('Login successful: ${userData['user']}');
        
        // IMPORTANT: Save user to AuthService
        if (mounted) {
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.login(
            _emailController.text.trim(), 
            _passwordController.text,
          ); // This will save the user data
          
          Navigator.pushReplacementNamed(context, appRoutes.crDashboardPage);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userData?['error'] ?? 'Invalid credentials'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: Check if server is running'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
          title: Text('Login', style: theme.appBarTheme.titleTextStyle),
          backgroundColor: theme.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9._%+-@]")),
                ],
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'lecturer@test.com',
                  prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
                ).applyDefaults(inputTh),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                style: textTh.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'password123',
                  prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
                ).applyDefaults(inputTh),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: double.infinity, height: 48),
                child: ElevatedButton(
                  style: btnTh,
                  onPressed: _loading ? null : _loginWithApi,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New User?', style: textTh.bodyMedium),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, appRoutes.signupPage),
                    child: Text('Sign Up', style: textTh.labelLarge),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}