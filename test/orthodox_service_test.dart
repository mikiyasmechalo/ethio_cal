import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';
import 'package:ethio_cal/models/calendar_event.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';

void main() {
  group('OrthodoxCalendarService Tests', () {
    test('Evangelist 4-year cycle names', () {
      expect(OrthodoxCalendarService.getYearName(2014), 'ዘመነ ማርቆስ');
      expect(OrthodoxCalendarService.getYearName(2015), 'ዘመነ ሉቃስ');
      expect(OrthodoxCalendarService.getYearName(2016), 'ዘመነ ዮሐንስ');
      expect(OrthodoxCalendarService.getYearName(2017), 'ዘመነ ማቴዎስ');
      expect(OrthodoxCalendarService.getYearName(2018), 'ዘመነ ማርቆስ');
    });

    test('Bahire Hasab Nineveh (ጾመ ነነዌ) accuracy', () {
      // 2014: Yekatit 7
      final n2014 = OrthodoxCalendarService.getNeneweDate(2014);
      expect(n2014.month, 6);
      expect(n2014.day, 7);

      // 2015: Tir 29
      final n2015 = OrthodoxCalendarService.getNeneweDate(2015);
      expect(n2015.month, 5);
      expect(n2015.day, 29);

      // 2016: Yekatit 18
      final n2016 = OrthodoxCalendarService.getNeneweDate(2016);
      expect(n2016.month, 6);
      expect(n2016.day, 18);

      // 2017: Yekatit 3
      final n2017 = OrthodoxCalendarService.getNeneweDate(2017);
      expect(n2017.month, 6);
      expect(n2017.day, 3);

      // 2018: Tir 25
      final n2018 = OrthodoxCalendarService.getNeneweDate(2018);
      expect(n2018.month, 5);
      expect(n2018.day, 25);
    });

    test('Event generation and 4 categories check', () {
      final allEvents = OrthodoxCalendarService.getAllYearEvents(2017);
      expect(allEvents.isNotEmpty, true);

      // Check all 4 categories exist
      final hasFeast = allEvents.any((e) => e.category == EventCategory.orthodoxFeast);
      final hasFasting = allEvents.any((e) => e.category == EventCategory.fasting);
      final hasMuslim = allEvents.any((e) => e.category == EventCategory.muslimHoliday);
      final hasNational = allEvents.any((e) => e.category == EventCategory.nationalHoliday);

      expect(hasFeast, true);
      expect(hasFasting, true);
      expect(hasMuslim, true);
      expect(hasNational, true);

      // Check master toggle OFF (exclude orthodox)
      final secularOnly = OrthodoxCalendarService.getAllYearEvents(2017, includeOrthodox: false);
      expect(secularOnly.any((e) => e.category == EventCategory.orthodoxFeast), false);
      expect(secularOnly.any((e) => e.category == EventCategory.fasting), false);
      expect(secularOnly.any((e) => e.category == EventCategory.nationalHoliday), true);
    });

    test('OrthodoxDayNames dataset integrity', () {
      expect(OrthodoxDayNames.monthlySaints.length, 30);
      expect(OrthodoxDayNames.getPrimarySaint(1, 12), 'ቅዱስ ሚካኤል');
      expect(OrthodoxDayNames.getPrimarySaint(1, 19), 'ቅዱስ ገብርኤል');
      expect(OrthodoxDayNames.getPrimarySaint(1, 21), 'በዓለ እግዝእትነ ማርያም');
      expect(OrthodoxDayNames.getPrimarySaint(1, 23), 'ቅዱስ ጊዮርጊስ');
      expect(OrthodoxDayNames.getPrimarySaint(1, 27), 'መድኃኔዓለም');
      expect(OrthodoxDayNames.getPrimarySaint(1, 29), 'በዓለ ወልድ');
      expect(OrthodoxDayNames.getPrimarySaint(13, 3), 'ቅዱስ ሩፋኤል ሊቀ መላእክት');
    });
  });
}
