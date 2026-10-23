import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';
import 'package:ethio_cal/services/widget_service.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late String _ethiopianDate;
  late String _ethiopianDay;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  bool is24Hour = true;
  static const String _timeKey = 'is24Hour';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _updateDateStrings();
    _startSyncedTimer();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      is24Hour = prefs.getBool(_timeKey) ?? true;
    });
  }

  Future<void> _toggleTimeFormat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => is24Hour = value);
    await prefs.setBool(_timeKey, value);
  }

  void _updateDateStrings() {
    setState(() {
      _ethiopianDate = EthiopianDateService.getFormattedDate();
      _ethiopianDay = EthiopianDateService.getDayOnly();
    });
  }

  void _startSyncedTimer() {
    final now = DateTime.now();
    final int delay = (60 - now.second) * 1000 - now.millisecond;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _tick();
        _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _tick());
      }
    });
  }

  void _tick() => setState(() => _currentTime = DateTime.now());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final highlightColor = theme.highlightColor;
    final surfaceColor = theme.surfaceColor;
    final accentColor = theme.accentColor;
    final isDark = theme.isDark;

    final nowEt = ETDateTime.now();
    final primarySaint = OrthodoxDayNames.getPrimarySaint(nowEt.month, nowEt.day);
    final yearEvangelist = OrthodoxCalendarService.getYearName(nowEt.year);
    final todayEvents = OrthodoxCalendarService.getEventsForDay(
      nowEt.year,
      nowEt.month,
      nowEt.day,
      includeOrthodox: settings.enableOrthodoxFeatures,
    );

    var timeStyle = GoogleFonts.chauPhilomeneOne(
      fontSize: 140,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: highlightColor,
    );

    var dayStyle = GoogleFonts.chauPhilomeneOne(
      fontSize: 60,
      fontWeight: FontWeight.w900,
      color: highlightColor,
      height: 1.1,
    );

    var dateStyle = GoogleFonts.chauPhilomeneOne(
      fontSize: 28,
      color: highlightColor.withOpacity(0.7),
    );

    String hour = is24Hour
        ? DateFormat('HH').format(_currentTime)
        : DateFormat('hh').format(_currentTime);
    String minute = DateFormat('mm').format(_currentTime);
    String amPm = DateFormat('a').format(_currentTime);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 12h / 24h switcher
              Align(
                alignment: Alignment.centerRight,
                child: _buildTimeFormatSwitcher(highlightColor),
              ),

              const Spacer(flex: 1),

              // Time Clock
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(hour, style: timeStyle),
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: timeStyle.copyWith(
                            color: highlightColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    Text(minute, style: timeStyle),
                    if (!is24Hour) ...[
                      const SizedBox(width: 12),
                      Text(
                        amPm,
                        style: GoogleFonts.chauPhilomeneOne(
                          fontSize: 28,
                          color: highlightColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Day & Date
              Text(_ethiopianDay, style: dayStyle, textAlign: TextAlign.center),
              Text(_ethiopianDate, style: dateStyle, textAlign: TextAlign.center),

              // Orthodox Day Name & Evangelist section (when enabled)
              if (settings.enableOrthodoxFeatures) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accentColor.withOpacity(0.25)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.church_rounded, size: 16, color: accentColor),
                          const SizedBox(width: 6),
                          Text(
                            yearEvangelist,
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 13,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: highlightColor.withOpacity(0.3)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'የዕለቱ ታቦት: $primarySaint',
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 15,
                              color: highlightColor,
                            ),
                          ),
                        ],
                      ),
                      if (todayEvents.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: todayEvents.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: e.categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: e.categoryColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${e.title} (${e.categoryLabel})',
                                style: GoogleFonts.chauPhilomeneOne(
                                  fontSize: 11,
                                  color: e.categoryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 2),

              // Sync Button
              _buildSyncButton(highlightColor, surfaceColor, accentColor, isDark),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton(
    Color highlightColor,
    Color surfaceColor,
    Color accentColor,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        await WidgetService.updateHomeWidget();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: surfaceColor,
            content: Text(
              'Widgets Synced (መተግበሪያ ዊጅቶች ታድሰዋል)',
              style: GoogleFonts.chauPhilomeneOne(color: highlightColor),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlightColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              size: 18,
              color: accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              "SYNC WIDGETS",
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 15,
                letterSpacing: 1.2,
                color: highlightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFormatSwitcher(Color highlightColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _switchItem(
          "12h",
          !is24Hour,
          highlightColor,
          () => _toggleTimeFormat(false),
        ),
        const SizedBox(width: 16),
        _switchItem(
          "24h",
          is24Hour,
          highlightColor,
          () => _toggleTimeFormat(true),
        ),
      ],
    );
  }

  Widget _switchItem(
    String label,
    bool active,
    Color highlightColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? highlightColor : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.chauPhilomeneOne(
            color: active ? highlightColor : highlightColor.withOpacity(0.4),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
