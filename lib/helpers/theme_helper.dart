import 'package:flutter/material.dart';

class AppColors {
  static const orangePrimary = Color(0xffFF611A);
  static const orangeSecondary = Color(0xffFF9349);

  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color textColor(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).cardColor;
}

class AppShadows {
  static List<BoxShadow> defaultShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ];
  }
}