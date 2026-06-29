import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0d1f3c);
  static const navyLight = Color(0xFF1a3a6b);
  static const navyDark = Color(0xFF0a1628);
  static const gold = Color(0xFFc9973a);
  static const goldLight = Color(0xFFf0c060);
  static const bgGray = Color(0xFFf0f3f8);
  static const white = Colors.white;
  static const border = Color(0xFFe5e7eb);
  static const textGray = Color(0xFF6b7280);
  static const textDark = Color(0xFF1f2937);
  static const green = Color(0xFF16a34a);
  static const greenBg = Color(0xFFf0fdf4);
  static const blueBg = Color(0xFFeff6ff);
  static const blueText = Color(0xFF1d4ed8);
  static const purpleBg = Color(0xFFfaf5ff);
  static const purpleText = Color(0xFF7e22ce);
  static const yellowBg = Color(0xFFfefce8);
  static const yellowText = Color(0xFFa16207);
}

LinearGradient get navyGradient => const LinearGradient(
      colors: [AppColors.navy, AppColors.navyLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

LinearGradient get goldGradient => const LinearGradient(
      colors: [AppColors.gold, AppColors.goldLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

LinearGradient get sidebarGradient => const LinearGradient(
      colors: [AppColors.navyDark, AppColors.navy],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
