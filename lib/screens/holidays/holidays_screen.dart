import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  late int _selectedYear;
  // 0: All, 1: Public Holidays only, 2: Fasts only, 3: Church Feasts only
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedYear = EthiopianDateService.getCurrentYear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;
    final bool isOrthodox = settings.enableOrthodoxFeatures;

    final yearName = OrthodoxCalendarService.getYearName(_selectedYear);
    final allEvents = OrthodoxCalendarService.getAllYearEvents(
      _selectedYear,
      includeOrthodox: isOrthodox,
    );

    final filteredEvents = allEvents.where((e) {
      if (!isOrthodox) return true; // When Orthodox is off, all returned are public holidays
      if (_filterIndex == 1) return e.isPublicHoliday;
      if (_filterIndex == 2) return e.isFasting;
      if (_filterIndex == 3) return !e.isFasting && e.isOrthodox;
      return true;
    }).toList();

    final title = isOrthodox ? 'የአመቱ አጽዋማትና በዓላት' : 'የአመቱ የሕዝብ በዓላት';

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.chauPhilomeneOne(fontSize: 20, color: highlight),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: highlight, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Year Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: highlight, size: 30),
                  onPressed: () => setState(() => _selectedYear--),
                ),
                Column(
                  children: [
                    Text(
                      '$_selectedYear ዓ.ም',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: highlight,
                      ),
                    ),
                    if (isOrthodox)
                      Text(
                        yearName,
                        style: GoogleFonts.chauPhilomeneOne(fontSize: 14, color: accent),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: highlight, size: 30),
                  onPressed: () => setState(() => _selectedYear++),
                ),
              ],
            ),
          ),

          // Filter Chips (Only shown when Orthodox is ON; hidden when OFF since all are public holidays)
          if (isOrthodox)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _chip('ሁሉም (All)', 0, highlight, surface, accent),
                  const SizedBox(width: 8),
                  _chip('የሕዝብ በዓላት (Public)', 1, highlight, surface, accent),
                  const SizedBox(width: 8),
                  _chip('አጽዋማት (Fasts)', 2, highlight, surface, accent),
                  const SizedBox(width: 8),
                  _chip('የቤተክርስቲያን (Church)', 3, highlight, surface, accent),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ብሔራዊ እና ይፋዊ የዕረፍት በዓላት (${filteredEvents.length})',
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 13,
                    color: highlight.withOpacity(0.55),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Events List
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Text(
                      'ምንም ክንዋኔ አልተገኘም (No events found)',
                      style: GoogleFonts.chauPhilomeneOne(
                        color: highlight.withOpacity(0.4),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final monthName =
                          EthiopianDateService.monthMaps[event.month] ?? '';
                      final dateLabel = '$monthName ${event.day} ቀን';

                      // Gregorian Equivalent Date
                      String gcDateLabel = '';
                      try {
                        final etDate = ETDateTime(_selectedYear, event.month, event.day);
                        final gcDate = etDate.convertToGregorian();
                        gcDateLabel = DateFormat('MMM d, yyyy').format(gcDate);
                      } catch (_) {}

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: event.categoryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: event.categoryColor.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Elongated Capsule Indicator
                            Container(
                              width: 5,
                              height: 48,
                              decoration: BoxDecoration(
                                color: event.categoryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Event Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          event.title,
                                          style: GoogleFonts.chauPhilomeneOne(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: highlight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Category + Work Status Badges
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: event.categoryColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              event.categoryLabel,
                                              style: GoogleFonts.chauPhilomeneOne(
                                                fontSize: 10,
                                                color: event.categoryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: event.isPublicHoliday
                                                  ? Colors.redAccent.withOpacity(0.12)
                                                  : highlight.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              event.workStatusLabel,
                                              style: GoogleFonts.chauPhilomeneOne(
                                                fontSize: 9,
                                                color: event.isPublicHoliday
                                                    ? Colors.redAccent
                                                    : highlight.withOpacity(0.55),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Dual Date: Ethiopian & Gregorian
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: highlight.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        gcDateLabel.isNotEmpty
                                            ? '$dateLabel  •  $gcDateLabel (GC)'
                                            : dateLabel,
                                        style: GoogleFonts.chauPhilomeneOne(
                                          fontSize: 13,
                                          color: highlight.withOpacity(0.75),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (event.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      event.description,
                                      style: GoogleFonts.chauPhilomeneOne(
                                        fontSize: 12,
                                        color: highlight.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    int index,
    Color highlight,
    Color surface,
    Color accent,
  ) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.2) : surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accent : highlight.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 12,
            color: isSelected ? highlight : highlight.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
