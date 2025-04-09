// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _systemThemeEnabled = true;

  ThemeMode get themeMode => _systemThemeEnabled ? ThemeMode.system : _themeMode;
  bool get systemThemeEnabled => _systemThemeEnabled;
  bool get darkModeEnabled => _themeMode == ThemeMode.dark;

  Future<void> loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _systemThemeEnabled = prefs.getBool('systemTheme') ?? true;
    final theme = prefs.getString('theme');

    if (theme == 'ThemeMode.dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'ThemeMode.light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _themeMode.toString());
    notifyListeners();
  }

  Future<void> toggleSystemTheme(bool value) async {
    _systemThemeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('systemTheme', value);
    notifyListeners();
  }
}