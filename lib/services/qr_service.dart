import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendify/services/api_service.dart';

class QRService {
  // Generate QR code data for a class session
  static Future<String?> generateQRCodeData(String classId, String date) async {
    try {
      // Create unique token for this attendance session
      final token = _generateUniqueToken(classId, date);
      
      // Send to backend to store the token
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/qr/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'classId': classId,
          'date': date,
          'token': token,
          'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        return token;
      }
      return null;
    } catch (e) {
      print('Generate QR error: $e');
      return null;
    }
  }
  
  // Generate unique token
  static String _generateUniqueToken(String classId, String date) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final raw = '$classId-$date-$timestamp';
    return base64.encode(utf8.encode(raw)).substring(0, 32);
  }
  
  // Verify scanned QR code
  static Future<Map<String, dynamic>?> verifyQRCode(String qrData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/attendance/qr/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': qrData}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Verify QR error: $e');
      return null;
    }
  }
}