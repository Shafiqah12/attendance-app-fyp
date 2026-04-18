import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:attendify/services/api_service.dart';

class WriteNFCPage extends StatefulWidget {
  const WriteNFCPage({super.key});

  @override
  State<WriteNFCPage> createState() => _WriteNFCPageState();
}

class _WriteNFCPageState extends State<WriteNFCPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _nfcIdController = TextEditingController();
  bool _isWriting = false;
  bool _isReading = false;

  Future<void> _readNFCAndRegister() async {
    setState(() => _isReading = true);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final data = tag.data;
          String? nfcId;
          
          if (data['id'] != null) {
            nfcId = data['id'].toString();
          } else if (data['uid'] != null) {
            nfcId = data['uid'].toString();
          }
          
          await NfcManager.instance.stopSession();
          
          if (mounted && nfcId != null) {
            setState(() {
              _nfcIdController.text = nfcId!;
              _isReading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ NFC ID read: $nfcId'), backgroundColor: Colors.green),
            );
          } else if (mounted) {
            setState(() => _isReading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Failed to read NFC ID'), backgroundColor: Colors.red),
            );
          }
        },
      );
    } catch (e) {
      setState(() => _isReading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _registerNFC() async {
    final studentId = _studentIdController.text.trim();
    final nfcId = _nfcIdController.text.trim();
    
    if (studentId.isEmpty || nfcId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Student ID and scan NFC card'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isWriting = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/students/register-nfc'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'nfcId': nfcId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ NFC card registered successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isWriting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register NFC Card'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.nfc, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            const Text(
              'Register Student NFC Card',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Enter student ID (e.g., 2023637684)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nfcIdController,
              decoration: InputDecoration(
                labelText: 'NFC Card ID',
                hintText: 'Tap "Read NFC Card" to scan',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.nfc),
                suffixIcon: IconButton(
                  icon: Icon(_isReading ? Icons.hourglass_empty : Icons.nfc),
                  onPressed: _isReading ? null : _readNFCAndRegister,
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isWriting ? null : _registerNFC,
              icon: const Icon(Icons.save),
              label: Text(_isWriting ? 'Registering...' : 'Register NFC Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Enter Student ID (e.g., 2023637684)'),
                  Text('2. Tap "Read NFC Card"'),
                  Text('3. Tap student card on phone'),
                  Text('4. NFC ID will auto-fill'),
                  Text('5. Tap "Register NFC Card"'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}