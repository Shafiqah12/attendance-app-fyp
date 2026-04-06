import 'package:flutter/material.dart';


class customButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPress; // Corrected type

  const customButton({
    super.key,
    required this.buttonText,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress, // Removed `this.`
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF333333),
        foregroundColor: Color(0xffffffff),
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 18,
        ),
      ), // `style` should be before `child`
    );
  }
}


class customSamllButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPress; // Corrected type

  const customSamllButton({
    super.key,
    required this.buttonText,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress, // Removed `this.`
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF333333),
        foregroundColor: Color(0xffffffff),
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 14,
        ),
      ), 
    );
  }
}
