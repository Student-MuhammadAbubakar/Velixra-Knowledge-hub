import 'package:flutter/material.dart';

/// Centralized color palette matching the Velixra Knowledge Hub design.
/// Every screen pulls colors from here — never hardcode a color inline
/// in a widget, so the whole app's look can be adjusted from one place.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0E1428); // outer dark navy background
  static const Color navy = Color(0xFF15213F);        // card headers, primary buttons
  static const Color gold = Color(0xFFD4A72C);         // accent: buttons, progress bars, icons
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBody = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF1A1F2E);
  static const Color textSecondary = Color(0xFF8A8F98);
  static const Color statusGreen = Color(0xFF22C55E);
  static const Color divider = Color(0xFFE5E7EB);
}