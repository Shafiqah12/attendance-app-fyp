import 'package:flutter/material.dart';

class GridItem {
  final String title;
  final String? img;
  final IconData? icon;
  final Function(BuildContext) function;

  GridItem({
    required this.title,
    this.img,
    this.icon,
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
        if (item.img != null)
          Expanded(
            child: Image.asset(
              'Dashboard_Images/${item.img}',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        if (item.icon != null)
          Expanded(
            child: Icon(
              item.icon,
              size: 60,
              color: Colors.blue,
            ),
          ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}