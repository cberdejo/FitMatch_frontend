import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeEnum { Dark, Light }

class ThemeProvider extends ChangeNotifier {
  ThemeEnum currentTheme = ThemeEnum.Light;
  ThemeData? currentThemeData;

  static ThemeProvider? _instance;
  static ThemeProvider get instance {
    _instance ??= ThemeProvider._init();
    return _instance!;
  }

  ThemeProvider._init() {
    _loadThemeFromPrefs(); // Load theme from SharedPreferences when initialized
  }

  Future<void> _loadThemeFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt('theme');
    if (themeIndex != null) {
      currentTheme = ThemeEnum.values[themeIndex];
      await _generateThemeData();
      notifyListeners();
    }
  }

  Future<void> changeTheme(ThemeEnum theme) async {
    currentTheme = theme;
    await _generateThemeData();
    notifyListeners();
    _saveThemeToPrefs(); // Save selected theme to SharedPreferences
  }

  Future<void> _generateThemeData() async {
    String themeStr = await rootBundle.loadString(_getCurrentThemePath());
    Map themeJson = jsonDecode(themeStr);
    currentThemeData = ThemeDecoder.decodeThemeData(themeJson)!;
  }

  String _getCurrentThemePath() {
    switch (currentTheme) {
      case ThemeEnum.Dark:
        return 'assets/themes/dark_theme.json';
      case ThemeEnum.Light:
        return 'assets/themes/light_theme.json';
      default:
        return 'assets/themes/light_theme.json';
    }
  }

  Future<void> _saveThemeToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', currentTheme.index);
  }
}
