import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:attendify/services/qr_service.dart';

class QRGeneratorDialog extends StatelessWidget {
  final String classId;
  final String className;
  
  const QRGeneratorDialog({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Generate QR Code',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              className,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FutureBuilder<String?>(
              future: QRService.generateQRCodeData(classId, DateTime.now().toIso8601String().split('T').first),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (snapshot.hasError || snapshot.data == null) {
                  return const Column(
                    children: [
                      Icon(Icons.error, size: 50, color: Colors.red),
                      SizedBox(height: 8),
                      Text('Failed to generate QR code'),
                    ],
                  );
                }
                
                return Column(
                  children: [
                    QrImageView(
                      data: snapshot.data!,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scan this QR code to mark attendance',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Valid for 5 minutes only',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}