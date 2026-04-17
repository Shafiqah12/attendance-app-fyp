import 'package:flutter/material.dart';
import 'package:attendify/Parts/appDrawer.dart';

class GenerateReports extends StatelessWidget {
  const GenerateReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Generate Report'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Report feature coming soon'),
            SizedBox(height: 8),
            Text('This will generate attendance reports in Excel format'),
          ],
        ),
      ),
    );
  }
}