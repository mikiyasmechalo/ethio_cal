import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';

class YearOverviewGrid extends StatelessWidget {
  final int currentYear;
  final int selectedMonth;
  final bool enableOrthodox;
  final Color highlightColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color scaffoldColor;
  final Function(int year) onYearChanged;
  final Function(int month, int year) onSelectMonth;
  final VoidCallback onClose;

  const YearOverviewGrid({
    super.key,
    required this.currentYear,
    required this.selectedMonth,
    required this.enableOrthodox,
    required this.highlightColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.scaffoldColor,
    required this.onYearChanged,
    required this.onSelectMonth,
    required this.onClose,
  });

  static const List<String> monthNames = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታህሳስ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሀሴ',
    'ጳጉሜ',
  ];

  static const List<String> gregorianRanges = [
    'Sep - Oct',
    'Oct - Nov',
    'Nov - Dec',
    'Dec - Jan',
    'Jan - Feb',
    'Feb - Mar',
    'Mar - Apr',
    'Apr - May',
    'May - Jun',
    'Jun - Jul',
    'Jul - Aug',
    'Aug - Sep',
    'Sep (5/6 days)',
  ];

  @override
  Widget build(BuildContext context) {
    final yearEvangelist = OrthodoxCalendarService.getYearName(currentYear);
    final allYearEvents = OrthodoxCalendarService.getAllYearEvents(
      currentYear,
      includeOrthodox: enableOrthodox,
    );

    return Container(
      color: scaffoldColor,
      child: Column(
        children: [
          // Year Navigation Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: highlightColor),
                  onPressed: () => onYearChanged(currentYear - 1),
                ),
                Column(
                  children: [
                    Text(
                      '$currentYear ዓ.ም',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 22,
                        color: highlightColor,
                      ),
                    ),
                    if (enableOrthodox)
                      Text(
                        yearEvangelist,
                        style: GoogleFonts.chauPhilomeneOne(
                          fontSize: 12,
                          color: accentColor,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: highlightColor),
                  onPressed: () => onYearChanged(currentYear + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 13-Month Grid View
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: 13,
              itemBuilder: (context, index) {
                final monthNum = index + 1;
                final isCurrent = monthNum == selectedMonth;
                final monthName = monthNames[index];
                final gcRange = gregorianRanges[index];
                final monthEvents = allYearEvents.where((e) => e.month == monthNum).toList();

                return GestureDetector(
                  onTap: () => onSelectMonth(monthNum, currentYear),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent ? accentColor.withOpacity(0.18) : surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent ? accentColor : highlightColor.withOpacity(0.08),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$monthNum',
                              style: GoogleFonts.chauPhilomeneOne(
                                fontSize: 13,
                                color: isCurrent ? accentColor : highlightColor.withOpacity(0.4),
                              ),
                            ),
                            if (monthEvents.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${monthEvents.length}',
                                  style: GoogleFonts.chauPhilomeneOne(
                                    fontSize: 10,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          monthName,
                          style: GoogleFonts.chauPhilomeneOne(
                            fontSize: 15,
                            color: isCurrent ? accentColor : highlightColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gcRange,
                          style: GoogleFonts.chauPhilomeneOne(
                            fontSize: 10,
                            color: highlightColor.withOpacity(0.45),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
