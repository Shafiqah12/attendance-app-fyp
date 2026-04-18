import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Theme/apptheme.dart';             
import 'package:attendify/util/appRoutes.dart';
import 'package:attendify/services/api_service.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/services/biometric_service.dart';
import 'package:attendify/services/secure_storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  
  // Biometric variables
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  String _biometricType = 'Biometric';
  IconData _biometricIcon = Icons.fingerprint;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if biometric is available on device
  Future<void> _checkBiometricAvailability() async {
    final available = await _biometricService.isBiometricAvailable();
    final typeName = await _biometricService.getBiometricTypeName();
    final icon = await _biometricService.getBiometricIcon();
    
    setState(() {
      _biometricAvailable = available;
      _biometricType = typeName;
      _biometricIcon = icon;
    });
  }

  // Login with biometric
  Future<void> _loginWithBiometric() async {
    if (_loading) return;
    
    setState(() => _loading = true);
    
    try {
      // Check if biometric is available
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _showSnackBar('Biometric not available on this device', Colors.orange);
        setState(() => _loading = false);
        return;
      }
      
      // Get saved credentials from secure storage
      final credentials = await SecureStorageService.getCredentials();
      
      if (credentials['email'] == null || credentials['email']!.isEmpty) {
        _showSnackBar('No saved credentials. Please login with email first.', Colors.orange);
        setState(() => _loading = false);
        return;
      }
      
      // Authenticate with biometric
      final isAuthenticated = await _biometricService.authenticate(
        reason: 'Please authenticate to login to Attendify',
      );
      
      if (isAuthenticated) {
        // Auto fill email and get password from storage
        _emailController.text = credentials['email']!;
        
        // Get password from storage (if saved)
        if (credentials['password'] != null) {
          _passwordController.text = credentials['password']!;
        }
        
        // Perform login
        await _performLogin(saveCredentials: false);
      } else {
        _showSnackBar('Authentication failed', Colors.red);
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Biometric login error: $e');
      _showSnackBar('Error: $e', Colors.red);
      setState(() => _loading = false);
    }
  }

  // Show snackbar helper
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Show dialog to enable biometric
  Future<void> _showEnableBiometricDialog() async {
    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable $_biometricType Login?'),
        content: Text(
          'Do you want to use $_biometricType to login next time?\n\n'
          'This will save your credentials securely on this device.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Enable $_biometricType'),
          ),
        ],
      ),
    );
    
    if (shouldEnable == true) {
      await SecureStorageService.setBiometricEnabled(true);
      _showSnackBar('$_biometricType login enabled!', Colors.green);
    }
  }

  // Login function using your API
  Future<void> _loginWithApi() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password', Colors.orange);
      return;
    }
    
    await _performLogin(saveCredentials: true);
  }
  
  // Core login logic
  Future<void> _performLogin({required bool saveCredentials}) async {
    setState(() => _loading = true);
    
    try {
      final userData = await ApiService.login(
        _emailController.text.trim(), 
        _passwordController.text,
      );
      
      if (userData != null && userData['success'] == true) {
        print('Login successful: ${userData['user']}');
        
        // Save credentials for biometric if requested
        if (saveCredentials) {
          await SecureStorageService.saveCredentials(
            _emailController.text.trim(),
            _passwordController.text,
          );
          
          // Ask user if they want to enable biometric login
          if (_biometricAvailable) {
            await _showEnableBiometricDialog();
          }
        }
        
        // Save user to AuthService
        if (mounted) {
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.login(
            _emailController.text.trim(), 
            _passwordController.text,
          );
          
          Navigator.pushReplacementNamed(context, appRoutes.crDashboardPage);
        }
      } else {
        if (mounted) {
          _showSnackBar(
            userData?['error'] ?? 'Invalid credentials',
            Colors.red,
          );
        }
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        _showSnackBar(
          'Connection error: Check if server is running',
          Colors.red,
        );
      }
      setState(() => _loading = false);
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
              // Email Field
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
              
              // Password Field
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
              
              // Email Login Button
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: double.infinity, height: 48),
                child: ElevatedButton(
                  style: btnTh,
                  onPressed: _loading ? null : _loginWithApi,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Login with Email'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Biometric Login Button (if available)
              if (_biometricAvailable)
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: double.infinity, height: 48),
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _loginWithBiometric,
                    icon: Icon(_biometricIcon, size: 24),
                    label: Text(
                      'Login with $_biometricType',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
      
              const SizedBox(height: 20),
              
              // Sign Up link
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