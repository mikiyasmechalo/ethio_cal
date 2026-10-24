import 'package:flutter_test/flutter_test.dart';
import 'package:ethio_cal/main.dart';
import 'package:ethio_cal/providers/settings_provider.dart';
import 'package:ethio_cal/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test loads successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsProvider = SettingsProvider();
    await settingsProvider.init();
    final themeProvider = ThemeProvider();
    await themeProvider.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
