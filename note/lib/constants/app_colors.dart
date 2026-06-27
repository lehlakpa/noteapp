import 'package:flutter/material.dart';

/// Centralized app colors (blue + white + commonly used text colors).
class AppColors {
  // Base colors
  static const Color blue = Color(0xFF1DA1F2); // primary brand blue
  static const Color white = Color(0xFFFFFFFF);

  // Backgrounds / surfaces
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text colors
  static const Color primaryText = Color(0xFF0F172A);
  static const Color mutedText = Color(0xFF64748B);
  static const Color mutedOnDarkText = Color(0xB3FFFFFF); // ~70% opacity

  // Convenience colors
  static const Color shadowLight = Color(0x1A000000); // subtle black with alpha
}
