import 'package:flutter/material.dart';
import 'package:attendify/services/api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _currentUser;
  
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get userId => _currentUser?['id']?.toString();
  String? get userEmail => _currentUser?['email'];
  String? get userName => _currentUser?['name'];
  String? get userRole => _currentUser?['role'];
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      final result = await ApiService.login(email, password);
      if (result != null && result['success'] == true) {
        _currentUser = result['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> signup(String name, String email, String password, String role) async {
    try {
      final result = await ApiService.signup(name, email, password, role);
      if (result != null && result['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }
}