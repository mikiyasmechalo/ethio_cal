import 'package:ethio_cal/models/calendar_event.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';

class OrthodoxCalendarService {
  /// Returns the 4-year cyclic Evangelist name for an Ethiopian year.
  /// (1=ማቴዎስ, 2=ማርቆስ, 3=ሉቃስ, 0=ዮሐንስ)
  static String getYearName(int year) {
    switch (year % 4) {
      case 1:
        return 'ዘመነ ማቴዎስ';
      case 2:
        return 'ዘመነ ማርቆስ';
      case 3:
        return 'ዘመነ ሉቃስ';
      case 0:
        return 'ዘመነ ዮሐንስ';
      default:
        return '';
    }
  }

  /// Returns whether the Ethiopian year is a leap year (Pagumen has 6 days).
  static bool isLeapYear(int year) {
    return (year + 1) % 4 == 0 || year % 4 == 3;
  }

  /// Calculates the Fast of Nineveh (ጾመ ነነዌ) base date for an Ethiopian year
  /// using the authentic Bahire Hasab (ባሕረ ሐሳብ) astronomical algorithm.
  static ETDateTime getNeneweDate(int year) {
    final int v6 = year + 8;
    final int v0 = ((v6 % 19) * 19 + 15) % 30;
    final int v1 = (v6 % 7) * 4;
    final int v6Rem4 = (v6 % 4) * 2;
    final int t1 = (v0 * 6 + v1 + v6Rem4 + 6) % 7;
    final int dayOfYear = t1 + v0 + 136;
    final int month = (dayOfYear ~/ 30) + 1;
    final int day = dayOfYear - ((dayOfYear ~/ 30) * 30) + 1;
    return ETDateTime(year, month, day);
  }

  /// Adds a number of days to an Ethiopian date respecting the 30-day month rule.
  static ETDateTime addDays(ETDateTime base, int days) {
    // In Ethiopian calendar, months 1-12 have 30 days.
    // Calculate total absolute days from Meskerem 1
    int totalDays = ((base.month - 1) * 30) + base.day + days;
    int year = base.year;

    while (totalDays <= 0) {
      year--;
      final daysInYear = isLeapYear(year) ? 366 : 365;
      totalDays += daysInYear;
    }

    final daysInThisYear = isLeapYear(year) ? 366 : 365;
    while (totalDays > daysInThisYear) {
      totalDays -= daysInThisYear;
      year++;
    }

    int month = (totalDays - 1) ~/ 30 + 1;
    int day = (totalDays - 1) % 30 + 1;
    if (month > 13) {
      month = 13;
      day = totalDays - (12 * 30);
    }
    return ETDateTime(year, month, day);
  }

  /// Returns all calendar events for a given Ethiopian year.
  /// Categorized into:
  /// - Orthodox Feasts (🟡)
  /// - Orthodox Fasts (🟣)
  /// - Muslim Holidays (🟢)
  /// - National Holidays (🔴)
  static List<CalendarEvent> getAllYearEvents(
    int year, {
    bool includeOrthodox = true,
  }) {
    final events = <CalendarEvent>[];

    // 1. National & International Public Holidays (🔴)
    events.add(CalendarEvent(
      title: 'የዘመን መለወጫ (እንቁጣጣሽ)',
      month: 1,
      day: 1,
      year: year,
      category: EventCategory.nationalHoliday,
      description: 'የኢትዮጵያ አዲስ ዓመት መጀመሪያ ቀን።',
    ));

    events.add(CalendarEvent(
      title: 'የዓድዋ ድል በዓል',
      month: 6,
      day: 23,
      year: year,
      category: EventCategory.nationalHoliday,
      description: 'የኢትዮጵያ የዓድዋ ድል መታሰቢያ በዓል።',
    ));

    events.add(CalendarEvent(
      title: 'የዓለም የሠራተኞች ቀን',
      month: 8,
      day: 23,
      year: year,
      category: EventCategory.nationalHoliday,
      description: 'ዓለም አቀፍ የሠራተኞች ቀን።',
    ));

    events.add(CalendarEvent(
      title: 'የአርበኞች ድል ቀን',
      month: 8,
      day: 27,
      year: year,
      category: EventCategory.nationalHoliday,
      description: 'የኢትዮጵያ አርበኞች ድል መታሰቢያ ቀን።',
    ));

    events.add(CalendarEvent(
      title: 'የደርግ ውድቀት ቀን',
      month: 9,
      day: 20,
      year: year,
      category: EventCategory.nationalHoliday,
      description: 'ብሔራዊ በዓል።',
    ));

    // 2. Islamic / Muslim Holidays (🟢)
    _addIslamicHolidays(events, year);

    // If Orthodox features are disabled, return only national + islamic holidays
    if (!includeOrthodox) {
      events.sort((a, b) {
        if (a.month != b.month) return a.month.compareTo(b.month);
        return a.day.compareTo(b.day);
      });
      return events;
    }

    // 3. Fixed Orthodox Feasts (🟡)
    events.add(CalendarEvent(
      title: 'የመስቀል በዓል',
      month: 1,
      day: 17,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የቅዱስ መስቀል መታሰቢያ በዓል።',
    ));

    final gennaDay = (year % 4 == 3) ? 28 : 29;
    events.add(CalendarEvent(
      title: 'የልደት በዓል (ገና)',
      month: 4,
      day: gennaDay,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የጌታችን የኢየሱስ ክርስቶስ የልደት በዓል።',
    ));

    events.add(CalendarEvent(
      title: 'የጥምቀት በዓል',
      month: 5,
      day: 11,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የጌታችን የጥምቀት በዓል።',
    ));

    events.add(CalendarEvent(
      title: 'ደብረ ታቦር (ቡሄ)',
      month: 12,
      day: 13,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የደብረ ታቦር በዓል።',
    ));

    events.add(CalendarEvent(
      title: 'የእመቤታችን ዕርገት (ፍልሰታ)',
      month: 12,
      day: 16,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የእመቤታችን የቅድስት ድንግል ማርያም የዕርገት በዓል።',
    ));

    // 4. Fixed Orthodox Fasts (🟣)
    events.add(CalendarEvent(
      title: 'ጾመ ነቢያት (የገና ጾም)',
      month: 3,
      day: 15,
      year: year,
      category: EventCategory.fasting,
      description: 'የገና ጾም መጀመሪያ (ለ44 ቀናት የሚቆይ)።',
    ));

    events.add(CalendarEvent(
      title: 'የጥምቀት ጋድ ጾም',
      month: 5,
      day: 10,
      year: year,
      category: EventCategory.fasting,
      description: 'የጥምቀት ዋዜማ ጋድ ጾም።',
    ));

    events.add(CalendarEvent(
      title: 'ጾመ ፍልሰታ',
      month: 12,
      day: 1,
      year: year,
      category: EventCategory.fasting,
      description: 'የፍልሰታ ለማርያም ጾም መጀመሪያ (እስከ ነሐሴ 15)።',
    ));

    // 5. Movable Feasts & Fasts (Relative to Nineveh via Bahire Hasab)
    final nenewe = getNeneweDate(year);

    events.add(CalendarEvent(
      title: 'ጾመ ነነዌ',
      month: nenewe.month,
      day: nenewe.day,
      year: year,
      category: EventCategory.fasting,
      description: 'የነነዌ ጾም መጀመሪያ (የ3 ቀናት ጾም)።',
    ));

    final abiyTsom = addDays(nenewe, 14);
    events.add(CalendarEvent(
      title: 'ዐቢይ ጾም (ሁዳዴ)',
      month: abiyTsom.month,
      day: abiyTsom.day,
      year: year,
      category: EventCategory.fasting,
      description: 'የዐቢይ ጾም መጀመሪያ (የ55 ቀናት ታላቅ ጾም)።',
    ));

    final debreZeyt = addDays(nenewe, 41);
    events.add(CalendarEvent(
      title: 'ደብረ ዘይት',
      month: debreZeyt.month,
      day: debreZeyt.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የደብረ ዘይት እኩለ ጾም በዓል።',
    ));

    final hosanna = addDays(nenewe, 62);
    events.add(CalendarEvent(
      title: 'ሆሳዕና',
      month: hosanna.month,
      day: hosanna.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የሆሳዕና እሑድ በዓል።',
    ));

    final siklet = addDays(nenewe, 67);
    events.add(CalendarEvent(
      title: 'ስቅለት (ዓርብ)',
      month: siklet.month,
      day: siklet.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የስቅለት መልካም ዓርብ መታሰቢያ።',
    ));

    final fasika = addDays(nenewe, 69);
    events.add(CalendarEvent(
      title: 'ትንሣኤ (ፋሲካ)',
      month: fasika.month,
      day: fasika.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የጌታችን የትንሣኤ (ፋሲካ) ታላቅ በዓል።',
    ));

    final rikbeKahnat = addDays(nenewe, 93);
    events.add(CalendarEvent(
      title: 'ርክበ ካህናት',
      month: rikbeKahnat.month,
      day: rikbeKahnat.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የርክበ ካህናት በዓል (ከፋሲካ በኋላ በ24ኛው ቀን)።',
    ));

    final erget = addDays(nenewe, 108);
    events.add(CalendarEvent(
      title: 'ዕርገት',
      month: erget.month,
      day: erget.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የጌታችን የዕርገት በዓል (ከፋሲካ በኋላ በ40ኛው ቀን)።',
    ));

    final peraklitos = addDays(nenewe, 118);
    events.add(CalendarEvent(
      title: 'ጰራቅሊጦስ (በዓለ ሃምሳ)',
      month: peraklitos.month,
      day: peraklitos.day,
      year: year,
      category: EventCategory.orthodoxFeast,
      description: 'የጰራቅሊጦስ በዓል (ከፋሲካ በኋላ በ50ኛው ቀን)።',
    ));

    final tsomeHawaryat = addDays(nenewe, 119);
    events.add(CalendarEvent(
      title: 'ጾመ ሐዋርያት (የሰኔ ጾም)',
      month: tsomeHawaryat.month,
      day: tsomeHawaryat.day,
      year: year,
      category: EventCategory.fasting,
      description: 'የሐዋርያት ጾም መጀመሪያ (ከሰኔ ጰራቅሊጦስ ማግስት)።',
    ));

    final tsomeDihnet = addDays(nenewe, 121);
    events.add(CalendarEvent(
      title: 'ጾመ ድኅነት',
      month: tsomeDihnet.month,
      day: tsomeDihnet.day,
      year: year,
      category: EventCategory.fasting,
      description: 'የረቡዕና ዓርብ ጾም መጀመሪያ።',
    ));

    // Sort chronologically by month then day
    events.sort((a, b) {
      if (a.month != b.month) return a.month.compareTo(b.month);
      return a.day.compareTo(b.day);
    });

    return events;
  }

  /// Calculates Islamic holidays for the given Ethiopian year.
  static void _addIslamicHolidays(List<CalendarEvent> events, int etYear) {
    // Convert Meskerem 1 of etYear to Gregorian to find start & end dates
    final gregStart = ETDateTime(etYear, 1, 1).convertToGregorian();
    final gregEnd = ETDateTime(etYear, 13, 5).convertToGregorian();

    // Scan Gregorian days in Ethiopian year and identify Hijri key days:
    // 1 Shawwal (Eid al-Fitr), 10 Dhu al-Hijjah (Eid al-Adha), 12 Rabi al-Awwal (Mawlid)
    DateTime current = gregStart;
    while (!current.isAfter(gregEnd)) {
      final jd = _gregorianToJd(current.year, current.month, current.day);
      final hijri = _jdToHijri(jd);
      final hMonth = hijri[1];
      final hDay = hijri[2];

      if (hMonth == 10 && hDay == 1) {
        final etDate = current.convertToEthiopian();
        if (etDate.year == etYear) {
          events.add(CalendarEvent(
            title: 'ዒድ አልፈጥር',
            month: etDate.month,
            day: etDate.day,
            year: etYear,
            category: EventCategory.muslimHoliday,
            description: 'የዒድ አልፈጥር በዓል።',
          ));
        }
      } else if (hMonth == 12 && hDay == 10) {
        final etDate = current.convertToEthiopian();
        if (etDate.year == etYear) {
          events.add(CalendarEvent(
            title: 'ዒድ አል አድሃ (አረፋ)',
            month: etDate.month,
            day: etDate.day,
            year: etYear,
            category: EventCategory.muslimHoliday,
            description: 'የአረፋ (ዒድ አል አድሃ) በዓል።',
          ));
        }
      } else if (hMonth == 3 && hDay == 12) {
        final etDate = current.convertToEthiopian();
        if (etDate.year == etYear) {
          events.add(CalendarEvent(
            title: 'መውሊድ (የነቢዩ መሐመድ ልደት)',
            month: etDate.month,
            day: etDate.day,
            year: etYear,
            category: EventCategory.muslimHoliday,
            description: 'የመውሊድ በዓል።',
          ));
        }
      }
      current = current.add(const Duration(days: 1));
    }
  }

  static double _gregorianToJd(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + (a ~/ 4);
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static List<int> _jdToHijri(double jd) {
    final jdInt = jd.floor() + 0.5;
    int l = jdInt.toInt() - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final m = (24 * l) ~/ 709;
    final d = l - (709 * m) ~/ 24;
    final y = 30 * n + j - 30;
    return [y, m, d];
  }

  /// Returns events map for a specific month (dayNum -> List of CalendarEvent).
  static Map<int, List<CalendarEvent>> getMonthEvents(
    int year,
    int month, {
    bool includeOrthodox = true,
  }) {
    final allEvents = getAllYearEvents(year, includeOrthodox: includeOrthodox);
    final monthMap = <int, List<CalendarEvent>>{};
    for (final event in allEvents) {
      if (event.month == month) {
        monthMap.putIfAbsent(event.day, () => []).add(event);
      }
    }
    return monthMap;
  }
}
