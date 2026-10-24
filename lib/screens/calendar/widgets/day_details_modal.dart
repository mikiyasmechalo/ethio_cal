import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/models/calendar_event.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';

class DayDetailsModal extends StatelessWidget {
  final int year;
  final int month;
  final int day;
  final List<CalendarEvent> events;
  final bool enableOrthodox;
  final Color highlightColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color scaffoldColor;

  const DayDetailsModal({
    super.key,
    required this.year,
    required this.month,
    required this.day,
    required this.events,
    required this.enableOrthodox,
    required this.highlightColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.scaffoldColor,
  });

  static void show(
    BuildContext context, {
    required int year,
    required int month,
    required int day,
    required List<CalendarEvent> events,
    required bool enableOrthodox,
    required Color highlightColor,
    required Color surfaceColor,
    required Color accentColor,
    required Color scaffoldColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailsModal(
        year: year,
        month: month,
        day: day,
        events: events,
        enableOrthodox: enableOrthodox,
        highlightColor: highlightColor,
        surfaceColor: surfaceColor,
        accentColor: accentColor,
        scaffoldColor: scaffoldColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final etDate = ETDateTime(year, month, day);
    final gcDate = etDate.convertToGregorian();
    final monthName = EthiopianDateService.monthMaps[month] ?? '';
    final gcFormatted = DateFormat('EEEE, MMMM d, yyyy').format(gcDate);
    final yearEvangelist = OrthodoxCalendarService.getYearName(year);
    final saints = OrthodoxDayNames.getAllSaintsFormatted(month, day);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: highlightColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ethiopian Date & Year
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$monthName $day ቀን $year ዓ.ም',
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 22,
                      color: highlightColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: highlightColor.withOpacity(0.5)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            // Gregorian Equivalent
            Text(
              gcFormatted,
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 13,
                color: highlightColor.withOpacity(0.5),
              ),
            ),

            if (enableOrthodox) ...[
              const SizedBox(height: 12),
              // Orthodox Evangelist & Day Commemoration
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.church_rounded, size: 16, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          yearEvangelist,
                          style: GoogleFonts.chauPhilomeneOne(
                            fontSize: 13,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    if (saints.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'የዕለቱ ታቦት / መታሰቢያ: $saints',
                        style: GoogleFonts.chauPhilomeneOne(
                          fontSize: 14,
                          color: highlightColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Events List
            Text(
              'በዓላትና ዝግጅቶች (Events)',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 15,
                color: highlightColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),

            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'በዚህ ቀን የተመዘገበ በዓል የለም (No events scheduled for this day)',
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 13,
                    color: highlightColor.withOpacity(0.4),
                  ),
                ),
              )
            else
              ...events.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: e.categoryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: e.categoryColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: e.categoryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.title,
                                      style: GoogleFonts.chauPhilomeneOne(
                                        fontSize: 16,
                                        color: highlightColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: e.categoryColor.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${e.categoryLabel} • ${e.workStatusLabel}',
                                      style: GoogleFonts.chauPhilomeneOne(
                                        fontSize: 10,
                                        color: e.categoryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (e.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  e.description,
                                  style: GoogleFonts.chauPhilomeneOne(
                                    fontSize: 12,
                                    color: highlightColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
