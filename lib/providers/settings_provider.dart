import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType {
  light,
  dark,
  brown,
  green,
  burgundy,
  blue,
}

class SettingsProvider extends ChangeNotifier {
  static const String _orthodoxFeaturesKey = 'enableOrthodoxFeatures';
  static const String _gregorianInCellKey = 'showGregorianInCell';
  static const String _themeTypeKey = 'appThemeType';

  bool _enableOrthodoxFeatures = true;
  bool _showGregorianInCell = true;
  AppThemeType _selectedTheme = AppThemeType.dark;

  bool get enableOrthodoxFeatures => _enableOrthodoxFeatures;
  bool get showGregorianInCell => _showGregorianInCell;
  AppThemeType get selectedTheme => _selectedTheme;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enableOrthodoxFeatures = prefs.getBool(_orthodoxFeaturesKey) ?? true;
    _showGregorianInCell = prefs.getBool(_gregorianInCellKey) ?? true;

    final themeIndex = prefs.getInt(_themeTypeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppThemeType.values.length) {
      _selectedTheme = AppThemeType.values[themeIndex];
    } else {
      // Backwards compatibility with old isDarkMode boolean
      final isDark = prefs.getBool('isDarkMode') ?? true;
      _selectedTheme = isDark ? AppThemeType.dark : AppThemeType.light;
    }
    notifyListeners();
  }

  Future<void> toggleOrthodoxFeatures(bool value) async {
    _enableOrthodoxFeatures = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orthodoxFeaturesKey, value);
    notifyListeners();
  }

  Future<void> toggleShowGregorianInCell(bool value) async {
    _showGregorianInCell = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gregorianInCellKey, value);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeType theme) async {
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeTypeKey, theme.index);
    // Keep isDarkMode key updated for legacy checks
    await prefs.setBool('isDarkMode', theme != AppThemeType.light);
    notifyListeners();
  }
}
