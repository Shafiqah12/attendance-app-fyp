import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPress;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: theme.cardTheme.shape is RoundedRectangleBorder
              ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
              : BorderRadius.circular(20),
        ),
        elevation: theme.elevatedButtonTheme.style?.elevation?.resolve({}) ?? 5,
        textStyle: theme.textTheme.titleLarge,
      ),
      child: Text(
        buttonText,
        style: theme.textTheme.titleLarge,
      ),
    );
  }
}

class GridItem {
  final String title;
  final String img;
  final Function(BuildContext) function;

  const GridItem({
    required this.title,
    required this.img,
    required this.function,
  });
}

class gridCardDashboard extends StatelessWidget {
  final GridItem item;

  const gridCardDashboard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Card(
        color: theme.colorScheme.surface,
        shape: theme.cardTheme.shape,
        elevation: theme.cardTheme.elevation ?? 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: theme.cardTheme.shape is RoundedRectangleBorder
                    ? (theme.cardTheme.shape as RoundedRectangleBorder)
                        .borderRadius
                    : BorderRadius.zero,
                child: Image.asset(
                  "Dashboard_Images/${item.img}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              item.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

