import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:provider/provider.dart';
import 'package:ethio_cal/models/calendar_event.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/screens/calendar/widgets/day_cell.dart';
import 'package:ethio_cal/screens/calendar/widgets/day_details_modal.dart';
import 'package:ethio_cal/screens/calendar/widgets/year_overview_grid.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<String> _months = [
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

  final List<String> _weekDays = [
    'እሁድ',
    'ሰኞ',
    'ማክሰኞ',
    'ረቡዕ',
    'ሐሙስ',
    'ዓርብ',
    'ቅዳሜ',
  ];

  late int _viewMonth, _viewYear;
  late int _todayDay, _todayMonth, _todayYear;
  int? _selectedDay;
  bool _isYearView = false;

  @override
  void initState() {
    super.initState();
    _todayDay = EthiopianDateService.getCurrentDay();
    _todayMonth = EthiopianDateService.getCurrentMonth();
    _todayYear = EthiopianDateService.getCurrentYear();
    _viewMonth = _todayMonth;
    _viewYear = _todayYear;
  }

  void _jumpToToday() {
    setState(() {
      _viewMonth = _todayMonth;
      _viewYear = _todayYear;
      _selectedDay = _todayDay;
      _isYearView = false;
    });
  }

  void _changeMonth(int off) {
    setState(() {
      _viewMonth += off;
      if (_viewMonth > 13) {
        _viewMonth = 1;
        _viewYear++;
      } else if (_viewMonth < 1) {
        _viewMonth = 13;
        _viewYear--;
      }
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final highlightColor = theme.highlightColor;
    final surfaceColor = theme.surfaceColor;
    final accentColor = theme.accentColor;
    final scaffoldColor = theme.scaffoldColor;
    final isDark = theme.isDark;

    int offset = EthiopianDateService.getFirstWeekdayOfMonth(
      _viewYear,
      _viewMonth,
    );
    int daysCount = EthiopianDateService.getDaysInMonth(_viewYear, _viewMonth);
    bool isShowingToday = (_viewMonth == _todayMonth && _viewYear == _todayYear);

    // Fetch categorized events for this month
    final List<CalendarEvent> monthEvents = OrthodoxCalendarService.getEventsForMonth(
      _viewYear,
      _viewMonth,
      includeOrthodox: settings.enableOrthodoxFeatures,
    );

    // Group events by day for fast lookup in cells
    final Map<int, List<CalendarEvent>> eventsByDay = {};
    for (final e in monthEvents) {
      eventsByDay.putIfAbsent(e.day, () => []).add(e);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            // Header
            _buildHeader(
              highlightColor,
              accentColor,
              isShowingToday,
              settings.enableOrthodoxFeatures,
            ),
            const SizedBox(height: 10),

            // Main Body: Year Overview or Month Grid
            Expanded(
              child: _isYearView
                  ? YearOverviewGrid(
                      currentYear: _viewYear,
                      selectedMonth: _viewMonth,
                      enableOrthodox: settings.enableOrthodoxFeatures,
                      highlightColor: highlightColor,
                      surfaceColor: surfaceColor,
                      accentColor: accentColor,
                      scaffoldColor: scaffoldColor,
                      onYearChanged: (newYear) => setState(() => _viewYear = newYear),
                      onSelectMonth: (month, year) {
                        setState(() {
                          _viewMonth = month;
                          _viewYear = year;
                          _isYearView = false;
                          _selectedDay = null;
                        });
                      },
                      onClose: () => setState(() => _isYearView = false),
                    )
                  : GestureDetector(
                      // Horizontal swipe gesture to switch months
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -180) {
                            // Swiped left -> next month
                            _changeMonth(1);
                          } else if (details.primaryVelocity! > 180) {
                            // Swiped right -> previous month
                            _changeMonth(-1);
                          }
                        }
                      },
                      child: Column(
                        children: [
                          _buildWeekdayLabels(highlightColor),
                          const Divider(height: 16, thickness: 0.5),

                          // Calendar 7xN Grid
                          Flexible(
                            flex: 5,
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                childAspectRatio: 1.15,
                              ),
                              itemCount: daysCount + offset,
                              itemBuilder: (context, index) {
                                if (index < offset) return const SizedBox.shrink();
                                int dayNum = index - offset + 1;
                                bool isToday = (dayNum == _todayDay && isShowingToday);
                                bool isSelected = (_selectedDay == dayNum);
                                final dayEvents = eventsByDay[dayNum] ?? [];

                                return DayCell(
                                  day: dayNum,
                                  month: _viewMonth,
                                  year: _viewYear,
                                  isToday: isToday,
                                  isSelected: isSelected,
                                  events: dayEvents,
                                  showGregorian: settings.showGregorianInCell,
                                  highlightColor: highlightColor,
                                  surfaceColor: surfaceColor,
                                  accentColor: accentColor,
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() => _selectedDay = dayNum);
                                    DayDetailsModal.show(
                                      context,
                                      year: _viewYear,
                                      month: _viewMonth,
                                      day: dayNum,
                                      events: dayEvents,
                                      enableOrthodox: settings.enableOrthodoxFeatures,
                                      highlightColor: highlightColor,
                                      surfaceColor: surfaceColor,
                                      accentColor: accentColor,
                                      scaffoldColor: scaffoldColor,
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Events List for this month
                          Expanded(
                            flex: 4,
                            child: _buildEventsSection(
                              monthEvents,
                              highlightColor,
                              surfaceColor,
                              accentColor,
                              scaffoldColor,
                              settings.enableOrthodoxFeatures,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'የኢትዮጵያ ዘመን አቆጣጠር (Ethiopian Calendar)',
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 11,
                  color: highlightColor.withOpacity(0.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianMonthRange(int etYear, int etMonth) {
    try {
      final daysInMonth = EthiopianDateService.getDaysInMonth(etYear, etMonth);
      final startGc = ETDateTime(etYear, etMonth, 1).convertToGregorian();
      final endGc = ETDateTime(etYear, etMonth, daysInMonth).convertToGregorian();
      final startStr = DateFormat('MMM').format(startGc);
      final endStr = DateFormat('MMM').format(endGc);
      if (startStr.toLowerCase() == endStr.toLowerCase()) {
        return startStr; // e.g. "Sep" for Pagumen
      }
      return '$startStr - $endStr'; // e.g. "Sep - Oct"
    } catch (_) {
      return '';
    }
  }

  Widget _buildHeader(
    Color highlightColor,
    Color accentColor,
    bool isShowingToday,
    bool enableOrthodox,
  ) {
    final yearName = enableOrthodox ? ' • ${OrthodoxCalendarService.getYearName(_viewYear)}' : '';
    final gcRange = _getGregorianMonthRange(_viewYear, _viewMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Year & Month (Tap to toggle Year Overview)
        GestureDetector(
          onTap: () => setState(() => _isYearView = !_isYearView),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$_viewYear ዓ.ም$yearName',
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 14,
                      color: highlightColor.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isYearView ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 16,
                    color: highlightColor.withOpacity(0.5),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _months[_viewMonth - 1],
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 32,
                      color: highlightColor,
                      height: 1.0,
                    ),
                  ),
                  if (gcRange.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '($gcRange)',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 16,
                        color: highlightColor.withOpacity(0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Navigation controls
        Row(
          children: [
            // Year view toggle button
            _navBtn(
              _isYearView ? Icons.calendar_today_rounded : Icons.grid_view_rounded,
              () => setState(() => _isYearView = !_isYearView),
              highlightColor,
            ),
            const SizedBox(width: 6),
            if (!isShowingToday) ...[
              _navBtn(Icons.today_rounded, _jumpToToday, highlightColor),
              const SizedBox(width: 6),
            ],
            if (!_isYearView) ...[
              _navBtn(Icons.chevron_left_rounded, () => _changeMonth(-1), highlightColor),
              const SizedBox(width: 6),
              _navBtn(Icons.chevron_right_rounded, () => _changeMonth(1), highlightColor),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays
          .map(
            (d) => Text(
              d,
              style: GoogleFonts.chauPhilomeneOne(
                color: color.withOpacity(0.45),
                fontSize: 13,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEventsSection(
    List<CalendarEvent> events,
    Color highlightColor,
    Color surfaceColor,
    Color accentColor,
    Color scaffoldColor,
    bool enableOrthodox,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "የወሩ በዓላትና ዝግጅቶች (EVENTS)",
              style: GoogleFonts.chauPhilomeneOne(fontSize: 15, color: highlightColor),
            ),
            if (events.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${events.length} በዓላት',
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 11,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Text(
                    "በዚህ ወር የተመዘገበ በዓል የለም (No events this month)",
                    style: GoogleFonts.chauPhilomeneOne(
                      color: highlightColor.withOpacity(0.35),
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDay = event.day);
                        DayDetailsModal.show(
                          context,
                          year: _viewYear,
                          month: _viewMonth,
                          day: event.day,
                          events: [event],
                          enableOrthodox: enableOrthodox,
                          highlightColor: highlightColor,
                          surfaceColor: surfaceColor,
                          accentColor: accentColor,
                          scaffoldColor: scaffoldColor,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: event.categoryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: event.categoryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 30,
                              decoration: BoxDecoration(
                                color: event.categoryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.chauPhilomeneOne(
                                      fontSize: 15,
                                      color: highlightColor,
                                    ),
                                  ),
                                  Text(
                                    '${_months[_viewMonth - 1]} ${event.day} ቀን',
                                    style: GoogleFonts.chauPhilomeneOne(
                                      fontSize: 12,
                                      color: highlightColor.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: event.categoryColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                enableOrthodox
                                    ? '${event.categoryLabel} • ${event.workStatusLabel}'
                                    : event.categoryLabel,
                                style: GoogleFonts.chauPhilomeneOne(
                                  fontSize: 10,
                                  color: event.categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.06),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
