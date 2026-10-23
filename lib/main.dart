import 'package:ethio_cal/my_widgets.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/services/update_widget_background.dart';
import 'package:ethio_cal/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_android_widgets/flutter_android_widgets.dart';
import 'package:provider/provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:ethio_cal/utils/app_router.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register all widget definitions so styles sync on hot restart / app resume
  WidgetUpdater.initialize(widgets: allWidgets);
  HomeWidgetData.autoUpdate = true;

  await AndroidAlarmManager.initialize();
  await WidgetService.updateHomeWidget();

  await AndroidAlarmManager.periodic(
    const Duration(hours: 1),
    0,
    updateWidgetBackground,
    startAt: DateTime.now().add(const Duration(seconds: 5)),
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
  );

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  final themeProvider = ThemeProvider();
  themeProvider.updateFromSettings(settingsProvider.selectedTheme);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Keep themeProvider in sync with settingsProvider
    themeProvider.updateFromSettings(settingsProvider.selectedTheme);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
