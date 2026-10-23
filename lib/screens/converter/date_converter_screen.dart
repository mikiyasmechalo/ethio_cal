import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:intl/intl.dart';

class DateConverterScreen extends StatefulWidget {
  const DateConverterScreen({super.key});

  @override
  State<DateConverterScreen> createState() => _DateConverterScreenState();
}

class _DateConverterScreenState extends State<DateConverterScreen> {
  // 0: GC to EC, 1: EC to GC
  int _tabIndex = 0;

  // GC -> EC state
  DateTime _selectedGregDate = DateTime.now();

  // EC -> GC state
  late int _etYear;
  late int _etMonth;
  late int _etDay;

  @override
  void initState() {
    super.initState();
    final nowEt = ETDateTime.now();
    _etYear = nowEt.year;
    _etMonth = nowEt.month;
    _etDay = nowEt.day;
  }

  void _resetToToday() {
    setState(() {
      _selectedGregDate = DateTime.now();
      final nowEt = ETDateTime.now();
      _etYear = nowEt.year;
      _etMonth = nowEt.month;
      _etDay = nowEt.day;
    });
  }

  Future<void> _pickGregorianDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedGregDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedGregDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ቀን መቀየሪያ (Date Converter)',
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 20,
            color: highlight,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: highlight, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'ዛሬ (Today)',
            icon: Icon(Icons.today, color: highlight),
            onPressed: _resetToToday,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Selector Tabs
            _buildTabSelector(highlight, surface, accent),
            const SizedBox(height: 24),

            if (_tabIndex == 0)
              _buildGcToEcSection(highlight, surface, accent, settings.enableOrthodoxFeatures)
            else
              _buildEcToGcSection(highlight, surface, accent, settings.enableOrthodoxFeatures),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(Color highlight, Color surface, Color accent) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'ከግሪጎሪያን ወደ ኢትዮጵያ',
              subtitle: 'GC → EC',
              isSelected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
              accent: accent,
              highlight: highlight,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _tabButton(
              title: 'ከኢትዮጵያ ወደ ግሪጎሪያን',
              subtitle: 'EC → GC',
              isSelected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
              accent: accent,
              highlight: highlight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accent,
    required Color highlight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accent.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 13,
                color: isSelected ? highlight : highlight.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 11,
                color: isSelected ? accent : highlight.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. GC -> EC
  Widget _buildGcToEcSection(
    Color highlight,
    Color surface,
    Color accent,
    bool enableOrthodox,
  ) {
    final etConverted = _selectedGregDate.convertToEthiopian();
    final monthName = EthiopianDateService.monthMaps[etConverted.month] ?? '';
    final weekdayName = _getEtWeekday(etConverted.weekday);
    final yearName = OrthodoxCalendarService.getYearName(etConverted.year);
    final saint = OrthodoxDayNames.getPrimarySaint(etConverted.month, etConverted.day);
    final formattedEt = '$monthName ${etConverted.day} ቀን ${etConverted.year} ዓ.ም';

    return Column(
      children: [
        // Picker Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'የግሪጎሪያን ቀን ይምረጡ (Pick Gregorian Date)',
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 14,
                  color: highlight.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _pickGregorianDate(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: highlight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: accent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(_selectedGregDate),
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 16,
                              color: highlight,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.edit_calendar, color: highlight.withOpacity(0.5), size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Result Card
        _buildResultCard(
          highlight: highlight,
          surface: surface,
          accent: accent,
          badge: 'የኢትዮጵያ ቀን (Ethiopian Date)',
          mainTitle: formattedEt,
          subtitle: '$weekdayName ($monthName)',
          additionalInfo: [
            if (enableOrthodox) ...[
              MapEntry('የዓመቱ ስም', yearName),
              if (saint.isNotEmpty) MapEntry('የዕለቱ ታቦት / በዓል', saint),
            ],
            MapEntry('በአሀዝ (Numeric)', '${etConverted.year}/${etConverted.month}/${etConverted.day}'),
          ],
          copyText: formattedEt,
        ),
      ],
    );
  }

  // 2. EC -> GC
  Widget _buildEcToGcSection(
    Color highlight,
    Color surface,
    Color accent,
    bool enableOrthodox,
  ) {
    final maxDays = EthiopianDateService.getDaysInMonth(_etYear, _etMonth);
    final safeDay = _etDay.clamp(1, maxDays);
    final etInput = ETDateTime(_etYear, _etMonth, safeDay);
    final gregConverted = etInput.convertToGregorian();
    final formattedGreg = DateFormat('EEEE, MMMM dd, yyyy').format(gregConverted);
    final yearName = OrthodoxCalendarService.getYearName(_etYear);
    final saint = OrthodoxDayNames.getPrimarySaint(_etMonth, safeDay);

    return Column(
      children: [
        // Ethiopian Date Selectors
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'የኢትዮጵያ ቀን ያስገቡ (Enter Ethiopian Date)',
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 14,
                  color: highlight.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Day Selector
                  Expanded(
                    flex: 2,
                    child: _dropdownField<int>(
                      label: 'ቀን (Day)',
                      value: safeDay,
                      items: List.generate(maxDays, (i) => i + 1),
                      itemLabel: (d) => '$d',
                      onChanged: (v) {
                        if (v != null) setState(() => _etDay = v);
                      },
                      highlight: highlight,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Month Selector
                  Expanded(
                    flex: 3,
                    child: _dropdownField<int>(
                      label: 'ወር (Month)',
                      value: _etMonth,
                      items: List.generate(13, (i) => i + 1),
                      itemLabel: (m) => '${EthiopianDateService.monthMaps[m]} ($m)',
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _etMonth = v;
                            final max = EthiopianDateService.getDaysInMonth(_etYear, _etMonth);
                            if (_etDay > max) _etDay = max;
                          });
                        }
                      },
                      highlight: highlight,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Year Selector
                  Expanded(
                    flex: 2,
                    child: _dropdownField<int>(
                      label: 'ዓመት (Year)',
                      value: _etYear,
                      items: List.generate(150, (i) => 1950 + i),
                      itemLabel: (y) => '$y',
                      onChanged: (v) {
                        if (v != null) setState(() => _etYear = v);
                      },
                      highlight: highlight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Result Card
        _buildResultCard(
          highlight: highlight,
          surface: surface,
          accent: accent,
          badge: 'የግሪጎሪያን ቀን (Gregorian Date)',
          mainTitle: formattedGreg,
          subtitle: 'Day ${gregConverted.day} of ${DateFormat('MMMM').format(gregConverted)}, ${gregConverted.year}',
          additionalInfo: [
            if (enableOrthodox) ...[
              MapEntry('የዓመቱ ስም', yearName),
              if (saint.isNotEmpty) MapEntry('የዕለቱ ታቦት / በዓል', saint),
            ],
            MapEntry('በአሀዝ (Numeric)', DateFormat('yyyy-MM-dd').format(gregConverted)),
          ],
          copyText: formattedGreg,
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    required Color highlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 11,
            color: highlight.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: highlight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              icon: Icon(Icons.arrow_drop_down, color: highlight.withOpacity(0.5)),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 14,
                      color: highlight,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required Color highlight,
    required Color surface,
    required Color accent,
    required String badge,
    required String mainTitle,
    required String subtitle,
    required List<MapEntry<String, String>> additionalInfo,
    required String copyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 12,
                    color: accent,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'ቅዳ (Copy)',
                icon: Icon(Icons.copy, size: 18, color: highlight.withOpacity(0.6)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: copyText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'ተቀድቷል (Copied to clipboard)!',
                        style: GoogleFonts.chauPhilomeneOne(color: Colors.white),
                      ),
                      backgroundColor: Colors.black87,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mainTitle,
            style: GoogleFonts.chauPhilomeneOne(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: highlight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.chauPhilomeneOne(
              fontSize: 15,
              color: highlight.withOpacity(0.6),
            ),
          ),
          const Divider(height: 24),
          ...additionalInfo.map((info) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    info.key,
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 13,
                      color: highlight.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    info.value,
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 14,
                      color: highlight,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getEtWeekday(int weekday) {
    const days = {
      1: 'ሰኞ',
      2: 'ማክሰኞ',
      3: 'ረቡዕ',
      4: 'ሐሙስ',
      5: 'ዓርብ',
      6: 'ቅዳሜ',
      7: 'እሁድ',
    };
    return days[weekday] ?? '';
  }
}
