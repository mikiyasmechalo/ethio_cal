import 'package:go_router/go_router.dart';
import 'package:ethio_cal/screens/home/home_screen.dart';
import 'package:ethio_cal/screens/today/today_screen.dart';
import 'package:ethio_cal/screens/calendar/calendar_screen.dart';
import 'package:ethio_cal/screens/converter/date_converter_screen.dart';
import 'package:ethio_cal/screens/holidays/holidays_screen.dart';
import 'package:ethio_cal/screens/day_names/orthodox_day_names_screen.dart';

class AppRouter {
  static const String todayRoute = '/today';
  static const String calendarRoute = '/calendar';
  static const String converterRoute = '/converter';
  static const String holidaysRoute = '/holidays';
  static const String dayNamesRoute = '/day-names';

  static final GoRouter router = GoRouter(
    initialLocation: calendarRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeScreen(navigationChild: child),
        routes: [
          GoRoute(
            path: todayRoute,
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: calendarRoute,
            builder: (context, state) => const CalendarScreen(),
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
    ],
  );
}
