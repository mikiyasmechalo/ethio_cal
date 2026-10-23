import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/app_constants.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';
import 'package:ethio_cal/utils/app_router.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final highlight = theme.highlightColor;
    final surface = theme.surfaceColor;
    final accent = theme.accentColor;

    final nowEt = ETDateTime.now();
    final monthName = EthiopianDateService.monthMaps[nowEt.month] ?? '';
    final yearName = OrthodoxCalendarService.getYearName(nowEt.year);
    final saint = OrthodoxDayNames.getPrimarySaint(nowEt.month, nowEt.day);

    return Drawer(
      backgroundColor: theme.scaffoldColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  bottom: BorderSide(color: highlight.withOpacity(0.08)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.calendar_month_rounded, color: accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 22,
                              color: highlight,
                            ),
                          ),
                          Text(
                            AppConstants.appSubtitle,
                            style: GoogleFonts.chauPhilomeneOne(
                              fontSize: 12,
                              color: highlight.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$monthName ${nowEt.day} ቀን ${nowEt.year} ዓ.ም',
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 16,
                      color: highlight,
                    ),
                  ),
                  if (settings.enableOrthodoxFeatures) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$yearName • $saint',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 12,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  // Navigation Links
                  _drawerItem(
                    icon: Icons.calendar_view_month_rounded,
                    title: 'የቀን መቁጠሪያ (Calendar)',
                    color: highlight,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(AppRouter.calendarRoute);
                    },
                  ),

                  _drawerItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'ቀን መቀየሪያ (Date Converter)',
                    color: highlight,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRouter.converterRoute);
                    },
                  ),

                  if (settings.enableOrthodoxFeatures) ...[
                    _drawerItem(
                      icon: Icons.church_rounded,
                      title: 'የአመቱ አጽዋማትና በዓላት (Holidays)',
                      color: highlight,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRouter.holidaysRoute);
                      },
                    ),

                    _drawerItem(
                      icon: Icons.auto_stories_rounded,
                      title: 'የዕለት ስሞች (Orthodox Day Names)',
                      color: highlight,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRouter.dayNamesRoute);
                      },
                    ),
                  ],

                  const Divider(height: 24),

                  // Switches Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'ቅንብሮች (Settings)',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 12,
                        color: highlight.withOpacity(0.4),
                      ),
                    ),
                  ),

                  // Master Orthodox Switch
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    activeThumbColor: accent,
                    title: Text(
                      'የኦርቶዶክስ ገጽታዎች',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 14,
                        color: highlight,
                      ),
                    ),
                    subtitle: Text(
                      'Orthodox Features',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 11,
                        color: highlight.withOpacity(0.5),
                      ),
                    ),
                    value: settings.enableOrthodoxFeatures,
                    onChanged: (val) => settings.toggleOrthodoxFeatures(val),
                  ),

                  // Show GC Date in Cell Switch
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    activeThumbColor: accent,
                    title: Text(
                      'የግሪጎሪያን ቀን በሴል አሳይ',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 14,
                        color: highlight,
                      ),
                    ),
                    subtitle: Text(
                      'Show GC dates in cells',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 11,
                        color: highlight.withOpacity(0.5),
                      ),
                    ),
                    value: settings.showGregorianInCell,
                    onChanged: (val) => settings.toggleShowGregorianInCell(val),
                  ),

                  const Divider(height: 24),

                  // Themes Palette
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'መተግበሪያ ቀለማት (Themes)',
                      style: GoogleFonts.chauPhilomeneOne(
                        fontSize: 12,
                        color: highlight.withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildThemeSelector(settings, highlight),

                  const Divider(height: 24),

                  // Share & About
                  _drawerItem(
                    icon: Icons.share_rounded,
                    title: 'መተግበሪያውን ያጋሩ (Share App)',
                    color: highlight,
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(text: AppConstants.shareMessage),
                      );
                    },
                  ),

                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'ስለ መተግበሪያው (About)',
                    color: highlight,
                    onTap: () => _showAboutDialog(context, highlight, accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: GoogleFonts.chauPhilomeneOne(
          fontSize: 14,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeSelector(SettingsProvider settings, Color highlight) {
    const themeColors = [
      MapEntry(AppThemeType.light, Color(0xFFF0F0F0)),
      MapEntry(AppThemeType.dark, Color(0xFF3D312A)),
      MapEntry(AppThemeType.brown, Color(0xFF8B5A2B)),
      MapEntry(AppThemeType.green, Color(0xFF2E6F40)),
      MapEntry(AppThemeType.burgundy, Color(0xFF800020)),
      MapEntry(AppThemeType.blue, Color(0xFF1E3A8A)),
    ];

    const themeNames = {
      AppThemeType.light: 'Light',
      AppThemeType.dark: 'Dark',
      AppThemeType.brown: 'Brown',
      AppThemeType.green: 'Green',
      AppThemeType.burgundy: 'Burgundy',
      AppThemeType.blue: 'Blue',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: themeColors.map((entry) {
          final isSelected = settings.selectedTheme == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => settings.setTheme(entry.key),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.amberAccent : highlight.withOpacity(0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amberAccent.withOpacity(0.5),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    themeNames[entry.key] ?? '',
                    style: GoogleFonts.chauPhilomeneOne(
                      fontSize: 10,
                      color: isSelected ? highlight : highlight.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, Color highlight, Color accent) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.calendar_month, color: accent),
              const SizedBox(width: 10),
              Text(
                AppConstants.appName,
                style: GoogleFonts.chauPhilomeneOne(color: highlight, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'የኢትዮጵያ ቀን መቁጠሪያ (Ethiopian Calendar App)',
                style: GoogleFonts.chauPhilomeneOne(color: highlight, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Built with Flutter. Includes full Ethiopian Orthodox Tewahedo Church features, Bahire Hasab calculations, movable & fixed fasts/feasts, and bidirectional date conversion.',
                style: GoogleFonts.chauPhilomeneOne(
                  color: highlight.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse(AppConstants.githubReleaseUrl),
                  mode: LaunchMode.externalApplication,
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, color: accent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Check GitHub Releases',
                        style: GoogleFonts.chauPhilomeneOne(
                          color: accent,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'ዝጋ (Close)',
                style: GoogleFonts.chauPhilomeneOne(color: accent),
              ),
            ),
          ],
        );
      },
    );
  }
}
