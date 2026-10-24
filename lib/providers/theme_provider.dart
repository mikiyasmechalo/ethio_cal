import 'package:flutter/material.dart';
import 'package:ethio_cal/providers/settings_provider.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.dark;

  AppThemeType get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme != AppThemeType.light;
  bool get isDark => isDarkMode;

  static const Color richBlack = Color(0xFF3D312A);

  void updateFromSettings(AppThemeType themeType) {
    if (_currentTheme != themeType) {
      _currentTheme = themeType;
      notifyListeners();
    }
  }

  Color get scaffoldColor {
    switch (_currentTheme) {
      case AppThemeType.light:
        return const Color(0xFFF7F7F8);
      case AppThemeType.dark:
        return const Color(0xFF121212); // Pure neutral dark
      case AppThemeType.brown:
        return richBlack; // Original warm brown (0xFF3D312A)
      case AppThemeType.green:
        return const Color(0xFF0D1A14);
      case AppThemeType.burgundy:
        return const Color(0xFF1C0A11);
      case AppThemeType.blue:
        return const Color(0xFF0A1322);
    }
  }

  Color get surfaceColor {
    switch (_currentTheme) {
      case AppThemeType.light:
        return Colors.white;
      case AppThemeType.dark:
        return const Color(0xFF1E1E1E); // Sleek neutral dark surface
      case AppThemeType.brown:
        return const Color(0xFF2C221D); // Original warm brown surface
      case AppThemeType.green:
        return const Color(0xFF162B21);
      case AppThemeType.burgundy:
        return const Color(0xFF2E121D);
      case AppThemeType.blue:
        return const Color(0xFF132238);
    }
  }

  Color get highlightColor {
    switch (_currentTheme) {
      case AppThemeType.light:
        return richBlack;
      case AppThemeType.dark:
        return Colors.white;
      case AppThemeType.brown:
        return Colors.white;
      case AppThemeType.green:
        return const Color(0xFFE4F5ED);
      case AppThemeType.burgundy:
        return const Color(0xFFFDE8EE);
      case AppThemeType.blue:
        return const Color(0xFFE4F0FB);
    }
  }

  Color get accentColor {
    switch (_currentTheme) {
      case AppThemeType.light:
        return const Color(0xFF7D6B5D);
      case AppThemeType.dark:
        return const Color(0xFFD1D5DB); // Neutral silver accent
      case AppThemeType.brown:
        return const Color(0xFFC4B5A5); // Original warm brown accent
      case AppThemeType.green:
        return const Color(0xFF52B788);
      case AppThemeType.burgundy:
        return const Color(0xFFF4A261);
      case AppThemeType.blue:
        return const Color(0xFF64DFDF);
    }
  }

  ThemeData get themeData {
    final isDark = isDarkMode;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldColor,
      cardColor: surfaceColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accentColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: highlightColor,
      ),
    );
  }

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
