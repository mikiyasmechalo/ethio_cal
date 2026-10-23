// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/providers/settings_provider.dart';

class Tabs extends StatelessWidget {
  final bool isSelected;
  final Function(bool) onTabChanged;

  const Tabs({super.key, required this.isSelected, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final contentColor = themeProvider.highlightColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (scaffoldCtx) => IconButton(
                  tooltip: 'ማውጫ (Menu)',
                  icon: Icon(Icons.menu_rounded, color: contentColor, size: 26),
                  onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              _buildTab(
                "Calendar",
                !isSelected,
                contentColor,
                () => onTabChanged(false),
              ),
              const SizedBox(width: 20),
              _buildTab(
                "Today",
                isSelected,
                contentColor,
                () => onTabChanged(true),
              ),
            ],
          ),
          IconButton(
            tooltip: isDark ? 'Light theme' : 'Dark theme',
            onPressed: () {
              final next = isDark ? AppThemeType.light : AppThemeType.dark;
              settingsProvider.setTheme(next);
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool active, Color contentColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? contentColor : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.chauPhilomeneOne(
            color: active ? contentColor : contentColor.withOpacity(0.5),
            fontSize: 16,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
