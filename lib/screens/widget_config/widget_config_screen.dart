import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';

class WidgetConfigThemeOption {
  final String key;
  final String name;
  final Color baseBgColor;
  final Color textColor;
  final Color subtextColor;
  final Color accentColor;
  final Color dotFilled;
  final Color dotUnfilled;

  const WidgetConfigThemeOption({
    required this.key,
    required this.name,
    required this.baseBgColor,
    required this.textColor,
    required this.subtextColor,
    required this.accentColor,
    required this.dotFilled,
    required this.dotUnfilled,
  });
}

class WidgetConfigScreen extends StatefulWidget {
  final int? appWidgetId;
  final String? initialWidgetType;

  const WidgetConfigScreen({
    super.key,
    this.appWidgetId,
    this.initialWidgetType,
  });

  @override
  State<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends State<WidgetConfigScreen> {
  static const _channel = MethodChannel('com.anexon.ethio_cal/widget_config');

  int _appWidgetId = 0;
  String _widgetType = 'date'; // 'date', 'day', 'progress_ethio', 'progress_greg'
  String _selectedThemeKey = 'dark';
  double _opacity = 0.80;
  bool _isLoading = true;

  String _ethiopianDate = '';
  String _ethiopianDay = '';
  String _ethiopianDayNumber = '';
  String _orthodoxSaint = '';
  Map<String, String> _ethioProgress = {};
  Map<String, String> _gregProgress = {};
  bool _orthodoxEnabled = true;

  final List<WidgetConfigThemeOption> _themeOptions = const [
    WidgetConfigThemeOption(
      key: 'dark',
      name: 'Pure Dark',
      baseBgColor: Color(0xFF1E1E1E),
      textColor: Color(0xFFFFFFFF),
      subtextColor: Color(0xFFB3B3B3),
      accentColor: Color(0xFFD6A87A),
      dotFilled: Color(0xFFFFFFFF),
      dotUnfilled: Color(0xFF555555),
    ),
    WidgetConfigThemeOption(
      key: 'light',
      name: 'Clean Light',
      baseBgColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF1A1A1A),
      subtextColor: Color(0xFF666666),
      accentColor: Color(0xFF7D6B5D),
      dotFilled: Color(0xFF1A1A1A),
      dotUnfilled: Color(0xFFCCCCCC),
    ),
    WidgetConfigThemeOption(
      key: 'brown',
      name: 'Warm Brown',
      baseBgColor: Color(0xFF2C221D),
      textColor: Color(0xFFFFFFFF),
      subtextColor: Color(0xFFC4B5A5),
      accentColor: Color(0xFFD6A87A),
      dotFilled: Color(0xFFFFFFFF),
      dotUnfilled: Color(0xFF6E5648),
    ),
    WidgetConfigThemeOption(
      key: 'green',
      name: 'Forest Green',
      baseBgColor: Color(0xFF162B21),
      textColor: Color(0xFFE4F5ED),
      subtextColor: Color(0xFFA3D9C0),
      accentColor: Color(0xFF52B788),
      dotFilled: Color(0xFF52B788),
      dotUnfilled: Color(0xFF2E4D3E),
    ),
    WidgetConfigThemeOption(
      key: 'burgundy',
      name: 'Burgundy',
      baseBgColor: Color(0xFF2E121D),
      textColor: Color(0xFFFDE8EE),
      subtextColor: Color(0xFFD69BAE),
      accentColor: Color(0xFFF4A261),
      dotFilled: Color(0xFFF4A261),
      dotUnfilled: Color(0xFF5A293C),
    ),
    WidgetConfigThemeOption(
      key: 'blue',
      name: 'Midnight Blue',
      baseBgColor: Color(0xFF132238),
      textColor: Color(0xFFE4F0FB),
      subtextColor: Color(0xFF9EC2E8),
      accentColor: Color(0xFF64DFDF),
      dotFilled: Color(0xFF64DFDF),
      dotUnfilled: Color(0xFF253B5A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _ethiopianDate = EthiopianDateService.getFormattedDate();
    _ethiopianDay = EthiopianDateService.getDayOnly();
    _ethiopianDayNumber = EthiopianDateService.getCurrentDay().toString();
    _ethioProgress = EthiopianDateService.getEthiopianProgressData();
    _gregProgress = EthiopianDateService.getGregorianProgressData();

    final prefs = await SharedPreferences.getInstance();
    final masterOrthodox = prefs.getBool('enableOrthodoxFeatures') ?? true;
    final showSaintOnWidgets = prefs.getBool('showOrthodoxDayNamesInWidgets') ?? false;
    _orthodoxEnabled = masterOrthodox && showSaintOnWidgets;
    final nowEt = ETDateTime.now();
    _orthodoxSaint = _orthodoxEnabled
        ? OrthodoxDayNames.getPrimarySaint(nowEt.month, nowEt.day)
        : '';

    int id = widget.appWidgetId ?? 0;
    String type = widget.initialWidgetType ?? '';

    try {
      final info = await _channel.invokeMapMethod<String, dynamic>('getWidgetInfo');
      if (info != null) {
        if (info['appWidgetId'] != null && info['appWidgetId'] != 0) {
          id = info['appWidgetId'] as int;
        }
        if (info['widgetType'] != null && (info['widgetType'] as String).isNotEmpty) {
          type = info['widgetType'] as String;
        }
        if (info['savedTheme'] != null) {
          _selectedThemeKey = info['savedTheme'] as String;
        }
        if (info['savedOpacity'] != null) {
          _opacity = (info['savedOpacity'] as num).toDouble();
        }
      }
    } catch (_) {
      // Method channel fallback
    }

    if (id != 0) {
      final savedType = prefs.getString('widget_${id}_type');
      if (savedType != null && savedType.isNotEmpty) {
        type = savedType;
      }
      final savedTheme = prefs.getString('widget_${id}_theme');
      if (savedTheme != null) {
        _selectedThemeKey = savedTheme;
      }
      final savedOpacity = prefs.getDouble('widget_${id}_opacity');
      if (savedOpacity != null) {
        _opacity = savedOpacity;
      }
    }

    if (type.isEmpty) {
      type = 'date';
    }

    setState(() {
      _appWidgetId = id;
      _widgetType = type;
      _isLoading = false;
    });
  }

  WidgetConfigThemeOption get _activeTheme {
    return _themeOptions.firstWhere(
      (t) => t.key == _selectedThemeKey,
      orElse: () => _themeOptions.first,
    );
  }

  String _colorToHex(Color color, {int? alphaOverride, bool includeAlpha = true}) {
    final hexR = color.red.toRadixString(16).padLeft(2, '0').toUpperCase();
    final hexG = color.green.toRadixString(16).padLeft(2, '0').toUpperCase();
    final hexB = color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
    if (!includeAlpha) {
      return '#$hexR$hexG$hexB';
    }
    final a = alphaOverride ?? color.alpha;
    final hexA = a.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$hexA$hexR$hexG$hexB';
  }

  String get _widgetTitle {
    switch (_widgetType) {
      case 'day_name':
        return 'Ethiopian Day Name';
      case 'day':
        return 'Ethiopian Day Number & Name';
      case 'progress_ethio':
        return 'Ethiopian Time Progress';
      case 'progress_greg':
        return 'Gregorian Time Progress';
      case 'date':
      default:
        return 'Ethiopian Date & Day';
    }
  }

  Future<void> _applyConfiguration() async {
    final active = _activeTheme;
    final alphaVal = (_opacity * 255).round().clamp(0, 255);
    final bgColorHex = _colorToHex(active.baseBgColor, alphaOverride: alphaVal);
    final textColorHex = _colorToHex(active.textColor);
    final subtextColorHex = _colorToHex(active.subtextColor);
    final accentColorHex = _colorToHex(active.accentColor);
    final dotFilledHex = _colorToHex(active.dotFilled, includeAlpha: false);
    final dotUnfilledHex = _colorToHex(active.dotUnfilled, includeAlpha: false);

    final prefs = await SharedPreferences.getInstance();

    if (_appWidgetId != 0) {
      await prefs.setString('widget_${_appWidgetId}_type', _widgetType);
      await prefs.setString('widget_${_appWidgetId}_bgColor', bgColorHex);
      await prefs.setString('widget_${_appWidgetId}_textColor', textColorHex);
      await prefs.setString('widget_${_appWidgetId}_subtextColor', subtextColorHex);
      await prefs.setString('widget_${_appWidgetId}_accentColor', accentColorHex);
      await prefs.setString('widget_${_appWidgetId}_dotFilled', dotFilledHex);
      await prefs.setString('widget_${_appWidgetId}_dotUnfilled', dotUnfilledHex);
      await prefs.setString('widget_${_appWidgetId}_theme', _selectedThemeKey);
      await prefs.setDouble('widget_${_appWidgetId}_opacity', _opacity);
    }

    // Also update global defaults so un-configured widgets match
    await prefs.setString('widget_default_bgColor', bgColorHex);
    await prefs.setString('widget_default_textColor', textColorHex);
    await prefs.setString('widget_default_subtextColor', subtextColorHex);
    await prefs.setString('widget_default_accentColor', accentColorHex);
    await prefs.setString('widget_default_dotFilled', dotFilledHex);
    await prefs.setString('widget_default_dotUnfilled', dotUnfilledHex);

    try {
      await _channel.invokeMethod('finishConfiguration', {
        'appWidgetId': _appWidgetId,
      });
    } catch (_) {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final active = _activeTheme;
    final currentBgColor = active.baseBgColor.withOpacity(_opacity);

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Widget Settings',
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 18,
            color: highlight,
          ),
        ),
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: highlight),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget target badge showing which widget is being customized
                    _buildWidgetBadge(surface, highlight, accent),
                    const SizedBox(height: 16),

                    // Live Interactive Preview
                    _buildPreviewCard(currentBgColor, active, highlight),
                    const SizedBox(height: 24),

                    // Color theme selector
                    Text(
                      'Theme Palettes',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 14,
                        color: highlight.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemePaletteGrid(surface, highlight),
                    const SizedBox(height: 24),

                    // Transparency Slider & Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transparency',
                          style: GoogleFonts.chauPhilomeneOne(
                            fontSize: 14,
                            color: highlight.withOpacity(0.7),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_opacity * 100).round()}%',
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 13,
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildOpacitySlider(accent),
                    const SizedBox(height: 8),
                    _buildPresetChips(surface, highlight, accent),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom action bar (Apply)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  top: BorderSide(color: highlight.withOpacity(0.08)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A87A),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 22, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'Apply Changes',
                        style: GoogleFonts.chauPhilomeneOne(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetBadge(Color surface, Color highlight, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.widgets_rounded, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customizing',
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 11,
                  color: highlight.withOpacity(0.5),
                ),
              ),
              Text(
                _widgetTitle,
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: highlight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Color currentBgColor, WidgetConfigThemeOption active, Color highlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.remove_red_eye_rounded, size: 16, color: highlight.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              'Live Preview',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 12,
                color: highlight.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Wallpaper backdrop simulation to highlight transparency
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2B5876),
                Color(0xFF4E4376),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: currentBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildPreviewContent(active),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(WidgetConfigThemeOption active) {
    final shadow = [
      Shadow(
        color: Colors.black.withOpacity(_opacity < 0.5 ? 0.8 : 0.4),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];

    switch (_widgetType) {
      case 'day_name':
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _ethiopianDay.isNotEmpty ? _ethiopianDay : 'ረቡዕ',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: active.textColor,
                shadows: shadow,
              ),
            ),
            if (_orthodoxEnabled && _orthodoxSaint.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                _orthodoxSaint,
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: active.accentColor,
                  shadows: shadow,
                ),
              ),
            ],
          ],
        );

      case 'day':
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _ethiopianDayNumber.isNotEmpty ? _ethiopianDayNumber : '18',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: active.textColor,
                shadows: shadow,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _ethiopianDay.isNotEmpty ? _ethiopianDay : 'ረቡዕ',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: active.subtextColor,
                shadows: shadow,
              ),
            ),
            if (_orthodoxEnabled && _orthodoxSaint.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                _orthodoxSaint,
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: active.accentColor,
                  shadows: shadow,
                ),
              ),
            ],
          ],
        );

      case 'progress_ethio':
        return _buildProgressPreview(
          active: active,
          labelDay: _ethioProgress['ethio_day_label'] ?? 'ሰኞ',
          percentDay: _ethioProgress['ethio_day_percent'] ?? '72%',
          labelWeek: _ethioProgress['ethio_week_label'] ?? 'ሳምንት 1',
          percentWeek: _ethioProgress['ethio_week_percent'] ?? '45%',
          labelMonth: _ethioProgress['ethio_month_label'] ?? 'ጥቅምት 17',
          percentMonth: _ethioProgress['ethio_month_percent'] ?? '56%',
          labelYear: _ethioProgress['ethio_year_label'] ?? '2017',
          percentYear: _ethioProgress['ethio_year_percent'] ?? '12%',
          shadow: shadow,
        );

      case 'progress_greg':
        return _buildProgressPreview(
          active: active,
          labelDay: _gregProgress['greg_day_label'] ?? 'MONDAY',
          percentDay: _gregProgress['greg_day_percent'] ?? '68%',
          labelWeek: _gregProgress['greg_week_label'] ?? 'WEEK 43',
          percentWeek: _gregProgress['greg_week_percent'] ?? '82%',
          labelMonth: _gregProgress['greg_month_label'] ?? 'OCTOBER 28',
          percentMonth: _gregProgress['greg_month_percent'] ?? '90%',
          labelYear: _gregProgress['greg_year_label'] ?? '2026',
          percentYear: _gregProgress['greg_year_percent'] ?? '81%',
          shadow: shadow,
        );

      case 'date':
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _ethiopianDate.isNotEmpty ? _ethiopianDate : 'ጥቅምት 17 2017',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: active.textColor,
                shadows: shadow,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _ethiopianDay.isNotEmpty ? _ethiopianDay : 'ሰኞ',
              style: GoogleFonts.chauPhilomeneOne(
                fontSize: 14,
                color: active.subtextColor,
                shadows: shadow,
              ),
            ),
            if (_orthodoxEnabled && _orthodoxSaint.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                _orthodoxSaint,
                style: GoogleFonts.chauPhilomeneOne(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: active.accentColor,
                  shadows: shadow,
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildProgressPreview({
    required WidgetConfigThemeOption active,
    required String labelDay,
    required String percentDay,
    required String labelWeek,
    required String percentWeek,
    required String labelMonth,
    required String percentMonth,
    required String labelYear,
    required String percentYear,
    required List<Shadow> shadow,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressRow(labelDay, percentDay, active, shadow),
        const SizedBox(height: 4),
        _buildProgressRow(labelWeek, percentWeek, active, shadow),
        const SizedBox(height: 4),
        _buildProgressRow(labelMonth, percentMonth, active, shadow),
        const SizedBox(height: 4),
        _buildProgressRow(labelYear, percentYear, active, shadow),
      ],
    );
  }

  Widget _buildProgressRow(
    String label,
    String percent,
    WidgetConfigThemeOption active,
    List<Shadow> shadow,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.chauPhilomeneOne(
              fontSize: 11,
              color: active.textColor,
              shadows: shadow,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(24, (i) {
              final isFilled = i < 15;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.0),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? active.dotFilled : active.dotUnfilled,
                ),
              );
            }),
          ),
        ),
        Text(
          percent,
          style: GoogleFonts.chauPhilomeneOne(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active.textColor,
            shadows: shadow,
          ),
        ),
      ],
    );
  }

  Widget _buildThemePaletteGrid(Color surface, Color highlight) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _themeOptions.map((opt) {
        final isSelected = _selectedThemeKey == opt.key;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedThemeKey = opt.key;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFD6A87A) : highlight.withOpacity(0.12),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD6A87A).withOpacity(0.3),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: opt.baseBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Color(0xFFD6A87A))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  opt.name,
                  style: GoogleFonts.chauPhilomeneOne(
                    fontSize: 12,
                    color: isSelected ? highlight : highlight.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpacitySlider(Color accent) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFFD6A87A),
        inactiveTrackColor: accent.withOpacity(0.2),
        thumbColor: const Color(0xFFD6A87A),
        overlayColor: const Color(0xFFD6A87A).withOpacity(0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      child: Slider(
        value: _opacity,
        min: 0.0,
        max: 1.0,
        divisions: 100,
        onChanged: (val) {
          setState(() {
            _opacity = val;
          });
        },
      ),
    );
  }

  Widget _buildPresetChips(Color surface, Color highlight, Color accent) {
    final presets = [1.0, 0.80, 0.50, 0.15];

    return Row(
      children: presets.map((val) {
        final percentLabel = '${(val * 100).round()}%';
        final isSelected = (_opacity - val).abs() < 0.05;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _opacity = val;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? accent.withOpacity(0.2) : surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? accent : highlight.withOpacity(0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    percentLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 12,
                      color: isSelected ? highlight : highlight.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
