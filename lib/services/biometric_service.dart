import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      return isAvailable;
    } catch (e) {
      print('Biometric check error: $e');
      return false;
    }
  }

  // Get list of available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Get biometrics error: $e');
      return [];
    }
  }

  // Get biometric type name for display
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }

  // Get biometric icon
  Future<IconData> getBiometricIcon() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.fingerprint;  // ← Guna fingerprint instead of biometric
    }
  }

  // Authenticate with biometric
  Future<bool> authenticate({
    required String reason,
    bool stickyAuth = true,
    bool biometricOnly = true,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
}