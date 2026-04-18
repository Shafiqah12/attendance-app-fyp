import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCService {
  static Future<String?> readNfcTag(BuildContext context) async {
    String? nfcId;
    
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _showSnackBar(context, 'NFC is not available on this device', Colors.red);
        return null;
      }

      _showScanningDialog(context);

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final data = tag.data;
          print('NFC Tag detected: $data');
          
          // Extract identifier from nfca
          if (data['nfca'] != null && data['nfca']['identifier'] != null) {
            final identifier = data['nfca']['identifier'] as List;
            nfcId = identifier.map((i) => i.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }
          
          await NfcManager.instance.stopSession();
          
          if (context.mounted) {
            Navigator.pop(context);
            if (nfcId != null) {
              _showSnackBar(context, '✅ Card detected! ID: $nfcId', Colors.green);
            } else {
              _showSnackBar(context, '❌ Could not read NFC ID from card', Colors.red);
            }
          }
        },
      );
    } catch (e) {
      print('NFC Error: $e');
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _showSnackBar(context, 'NFC Error: $e', Colors.red);
      }
      return null;
    }
    
    return nfcId;
  }

  static void _showScanningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scan NFC Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.nfc, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Please tap your student card on the back of the phone'),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}