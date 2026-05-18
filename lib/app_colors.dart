import 'package:flutter/material.dart';
import 'theme_manager.dart';

class AppColors {
  static Color get primary => ThemeManager().primary;
  static Color get secondary => ThemeManager().secondary;
  static Color get background => ThemeManager().background;
  static Color get card => ThemeManager().cardColor;
  static bool get isDark => ThemeManager().isDark;

  static List<Color> get gradient => [secondary, primary];
}