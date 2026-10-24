import 'package:flutter/material.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';

enum EventCategory {
  orthodoxFeast, // 🟡 Orthodox Feasts (መስቀል፣ ገና፣ ጥምቀት፣ ፋሲካ...)
  fasting,       // 🟣 Fasting Periods & Start Days (ጾመ ነነዌ፣ ዐቢይ ጾም፣ ፍልሰታ...)
  muslimHoliday, // 🟢 Muslim Holidays (ዒድ አልፈጥር፣ አረፋ፣ መውሊድ...)
  nationalHoliday, // 🔴 National & International Days (የዓድዋ ድል፣ የአርበኞች ቀን...)
}

class CalendarEvent {
  final String title;
  final int month;
  final int day;
  final int year;
  final EventCategory category;
  final String description;
  final bool isPublicHoliday; // true if offices, banks & schools are closed

  const CalendarEvent({
    required this.title,
    required this.month,
    required this.day,
    required this.year,
    required this.category,
    this.description = '',
    this.isPublicHoliday = false,
  });

  bool get isFasting => category == EventCategory.fasting;
  bool get isOrthodox =>
      category == EventCategory.orthodoxFeast || category == EventCategory.fasting;

  bool get isSunday {
    try {
      final etDate = ETDateTime(year, month, day);
      return etDate.weekday == 7;
    } catch (_) {
      return false;
    }
  }

  String get workStatusLabel {
    if (isPublicHoliday) return 'የዕረፍት ቀን';
    if (isSunday) return 'እሁድ';
    return 'የሥራ ቀን';
  }

  Color get categoryColor {
    switch (category) {
      case EventCategory.orthodoxFeast:
        return const Color(0xFFF59E0B); // Amber / Gold
      case EventCategory.fasting:
        return const Color(0xFF8B5CF6); // Purple / Violet
      case EventCategory.muslimHoliday:
        return const Color(0xFF10B981); // Emerald Green
      case EventCategory.nationalHoliday:
        return const Color(0xFFEF4444); // Crimson Red
    }
  }

  String get categoryLabel {
    switch (category) {
      case EventCategory.orthodoxFeast:
        return 'የኦርቶዶክስ በዓል';
      case EventCategory.fasting:
        return 'ጾም';
      case EventCategory.muslimHoliday:
        return 'የእስልምና በዓል';
      case EventCategory.nationalHoliday:
        return 'ብሔራዊ በዓል';
    }
  }

  @override
  String toString() => '$title ($month/$day/$year - $categoryLabel - ${isPublicHoliday ? "Public Holiday" : (isSunday ? "Sunday" : "Working Day")})';
}
