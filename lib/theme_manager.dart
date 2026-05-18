import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final Box _box = Hive.box('user');

  String get currentTheme => _box.get('theme', defaultValue: 'Pastel');

  void setTheme(String theme) {
    _box.put('theme', theme);
    notifyListeners();
  }

  Color get primary {
    switch (currentTheme) {
      case 'Dark': return const Color(0xFFBB86FC);
      case 'Nature': return const Color(0xFF4CAF50);
      case 'Ocean': return const Color(0xFF2196F3);
      default: return const Color(0xFFE8A0BF);
    }
  }

  Color get secondary {
    switch (currentTheme) {
      case 'Dark': return const Color(0xFF6200EE);
      case 'Nature': return const Color(0xFF81C784);
      case 'Ocean': return const Color(0xFF64B5F6);
      default: return const Color(0xFFFFB6C1);
    }
  }

  Color get background {
    switch (currentTheme) {
      case 'Dark': return const Color(0xFF121212);
      case 'Nature': return const Color(0xFFF1F8E9);
      case 'Ocean': return const Color(0xFFE3F2FD);
      default: return const Color(0xFFFFF0F5);
    }
  }

  Color get cardColor {
    switch (currentTheme) {
      case 'Dark': return const Color(0xFF1E1E1E);
      case 'Nature': return const Color(0xFFDCEDC8);
      case 'Ocean': return const Color(0xFFBBDEFB);
      default: return const Color(0xFFFFD6E7);
    }
  }

  bool get isDark => currentTheme == 'Dark';
}