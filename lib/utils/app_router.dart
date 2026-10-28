import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';
import 'package:ethio_cal/screens/home/home_screen.dart';
import 'package:ethio_cal/screens/today/today_screen.dart';
import 'package:ethio_cal/screens/calendar/calendar_screen.dart';
import 'package:ethio_cal/screens/converter/date_converter_screen.dart';
import 'package:ethio_cal/screens/holidays/holidays_screen.dart';
import 'package:ethio_cal/screens/day_names/orthodox_day_names_screen.dart';
import 'package:ethio_cal/screens/widget_config/widget_config_screen.dart';

class AppRouter {
  static const String todayRoute = '/today';
  static const String calendarRoute = '/calendar';
  static const String converterRoute = '/converter';
  static const String holidaysRoute = '/holidays';
  static const String dayNamesRoute = '/day-names';
  static const String widgetConfigRoute = '/widget-config';

  static String _determineInitialLocation() {
    final defaultRoute = ui.PlatformDispatcher.instance.defaultRouteName;
    if (defaultRoute.isNotEmpty && defaultRoute != '/' && defaultRoute.startsWith(widgetConfigRoute)) {
      return defaultRoute;
    }
    return calendarRoute;
  }

  static final GoRouter router = GoRouter(
    initialLocation: _determineInitialLocation(),
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeScreen(navigationChild: child),
        routes: [
          GoRoute(
            path: todayRoute,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
          GoRoute(
            path: calendarRoute,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: converterRoute,
        builder: (context, state) => const DateConverterScreen(),
      ),
      GoRoute(
        path: holidaysRoute,
        builder: (context, state) => const HolidaysScreen(),
      ),
      GoRoute(
        path: dayNamesRoute,
        builder: (context, state) => const OrthodoxDayNamesScreen(),
      ),
      GoRoute(
        path: widgetConfigRoute,
        builder: (context, state) {
          final idParam = state.uri.queryParameters['appWidgetId'];
          final typeParam = state.uri.queryParameters['widgetType'];
          final appWidgetId = int.tryParse(idParam ?? '') ?? 0;
          return WidgetConfigScreen(
            appWidgetId: appWidgetId,
            initialWidgetType: typeParam,
          );
        },
      ),
    ],
  );
}
