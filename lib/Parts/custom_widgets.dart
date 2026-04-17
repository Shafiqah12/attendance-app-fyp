// lib/Parts/custom_widgets.dart
import 'package:flutter/material.dart';

class GridItem {
  final String title;
  final String img;
  final Function(BuildContext) function;
  
  GridItem({
    required this.title,
    required this.img,
    required this.function,
  });
}

Widget gridCardDashboard({required GridItem item}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            'Dashboard_Images/${item.img}',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}