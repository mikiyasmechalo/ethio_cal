import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/models/calendar_event.dart';

class DayCell extends StatelessWidget {
  final int day;
  final int month;
  final int year;
  final bool isToday;
  final bool isSelected;
  final List<CalendarEvent> events;
  final bool showGregorian;
  final Color highlightColor;
  final Color surfaceColor;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.showGregorian,
    required this.highlightColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int? gregorianDay;
    if (showGregorian) {
      try {
        final et = ETDateTime(year, month, day);
        final gc = et.convertToGregorian();
        gregorianDay = gc.day;
      } catch (_) {}
    }

    // Determine cell background and borders
    Color bgColor = Colors.transparent;
    Border? border;

    if (isToday) {
      bgColor = accentColor;
    } else if (isSelected) {
      bgColor = highlightColor.withOpacity(0.12);
      border = Border.all(color: accentColor, width: 1.5);
    } else {
      border = Border.all(color: highlightColor.withOpacity(0.08));
    }

    final textColor = isToday ? Colors.white : highlightColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gregorian Day Indicator (Top-right corner)
            if (showGregorian && gregorianDay != null)
              Positioned(
                top: 3,
                right: 4,
                child: Text(
                  '$gregorianDay',
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 9,
                    color: isToday ? Colors.white.withOpacity(0.75) : highlightColor.withOpacity(0.35),
                  ),
                ),
              ),

            // Main Ethiopian Day Number
            Center(
              child: Text(
                '$day',
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 17,
                  color: textColor,
                ),
              ),
            ),

            // Event Category Color Indicators (Bottom)
            if (events.isNotEmpty)
              Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((e) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.white : e.categoryColor,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
