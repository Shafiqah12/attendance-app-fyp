import 'package:flutter/material.dart';

class EditClassPage extends StatelessWidget {
  final String classId;
  const EditClassPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Class'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.class_, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Edit Class ID: $classId'),
            const SizedBox(height: 16),
            const Text('Edit class feature coming soon'),
          ],
        ),
      ),
    );
  }
}