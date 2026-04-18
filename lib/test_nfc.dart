import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class TestNFCPage extends StatefulWidget {
  const TestNFCPage({super.key});

  @override
  State<TestNFCPage> createState() => _TestNFCPageState();
}

class _TestNFCPageState extends State<TestNFCPage> {
  String _result = 'Tap "Scan NFC" and hold card near phone';
  bool _isScanning = false;

  Future<void> _scanNFC() async {
    setState(() {
      _isScanning = true;
      _result = 'Scanning... Hold card near phone';
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        setState(() {
          _result = '❌ NFC is not available on this device';
          _isScanning = false;
        });
        return;
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final data = tag.data;
          print('NFC Tag: $data');
          
          String nfcId = '';
          
          // Try to get identifier from different locations
          if (data['nfca'] != null && data['nfca']['identifier'] != null) {
            final identifier = data['nfca']['identifier'] as List;
            nfcId = identifier.map((i) => i.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          } 
          else if (data['isodep'] != null && data['isodep']['identifier'] != null) {
            final identifier = data['isodep']['identifier'] as List;
            nfcId = identifier.map((i) => i.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }
          else if (data['mifareclassic'] != null && data['mifareclassic']['identifier'] != null) {
            final identifier = data['mifareclassic']['identifier'] as List;
            nfcId = identifier.map((i) => i.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }
          else if (data['id'] != null) {
            nfcId = data['id'].toString();
          }
          else if (data['uid'] != null) {
            nfcId = data['uid'].toString();
          }
          else if (data['identifier'] != null) {
            final identifier = data['identifier'] as List;
            nfcId = identifier.map((i) => i.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }
          
          await NfcManager.instance.stopSession();
          
          if (mounted) {
            setState(() {
              if (nfcId.isNotEmpty) {
                _result = '✅ NFC Card Detected!\nID: $nfcId\n\nCopy this ID to register in database.';
              } else {
                _result = '⚠️ Card detected but ID could not be read.\nRaw data: $data';
              }
              _isScanning = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test NFC Card'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nfc, size: 100, color: Colors.purple),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanNFC,
                icon: const Icon(Icons.nfc),
                label: Text(_isScanning ? 'Scanning...' : 'Scan NFC Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Instructions:\n1. Tap "Scan NFC Card"\n2. Hold your student card on the back of the phone\n3. NFC ID will appear\n4. Copy the ID to register in database',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}