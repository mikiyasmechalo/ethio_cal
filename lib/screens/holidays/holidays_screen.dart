import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ethio_cal/models/calendar_event.dart';
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
  // 0: All, 1: Fasting only, 2: Feasts only
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedYear = EthiopianDateService.getCurrentYear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;

    final yearName = OrthodoxCalendarService.getYearName(_selectedYear);
    final allEvents = OrthodoxCalendarService.getAllYearEvents(_selectedYear);

    final filteredEvents = allEvents.where((e) {
      if (_filterIndex == 1) return e.isFasting;
      if (_filterIndex == 2) {
        return e.category == EventCategory.orthodoxFeast ||
            e.category == EventCategory.muslimHoliday ||
            e.category == EventCategory.nationalHoliday;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'የአመቱ አጽዋማትና በዓላት',
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

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _chip('ሁሉም (All)', 0, highlight, surface, accent),
                const SizedBox(width: 8),
                _chip('አጽዋማት (Fasts)', 1, highlight, surface, accent),
                const SizedBox(width: 8),
                _chip('በዓላት (Feasts)', 2, highlight, surface, accent),
              ],
            ),
          ),

          const SizedBox(height: 10),

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
                      final dateLabel = '$monthName ${event.day}';

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
                            // Category Color Indicator
                            Container(
                              width: 5,
                              height: 44,
                              decoration: BoxDecoration(
                                color: event.categoryColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Event Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: event.categoryColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          event.categoryLabel,
                                          style: GoogleFonts.chauPhilomeneOne(
                                            fontSize: 11,
                                            color: event.categoryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: highlight.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        dateLabel,
                                        style: GoogleFonts.chauPhilomeneOne(
                                          fontSize: 13,
                                          color: highlight.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (event.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      event.description,
                                      style: GoogleFonts.chauPhilomeneOne(
                                        fontSize: 11,
                                        color: highlight.withOpacity(0.4),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              color: isSelected ? highlight : highlight.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
