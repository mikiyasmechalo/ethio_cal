import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:flutter_android_widgets/flutter_android_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static Future<void> updateHomeWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final enableOrthodox = prefs.getBool('enableOrthodoxFeatures') ?? true;
    final showDayNames = prefs.getBool('showOrthodoxDayNamesInWidgets') ?? false;

    final date = EthiopianDateService.getFormattedDate();
    final day = EthiopianDateService.getDayOnly();

    final ethioProgress = EthiopianDateService.getEthiopianProgressData();
    final gregProgress = EthiopianDateService.getGregorianProgressData();

    final nowEt = ETDateTime.now();
    // Only display saint name if both orthodox features AND showDayNames are enabled.
    final saint = (enableOrthodox && showDayNames)
        ? OrthodoxDayNames.getPrimarySaint(nowEt.month, nowEt.day)
        : '';
    final dayNumber = nowEt.day.toString();

    await HomeWidgetData.saveAll({
      'ethiopian_date': date,
      'ethiopian_day': day,
      'ethiopian_day_number': dayNumber,
      'orthodox_saint': saint,
      'orthodox_year': '', // Intentionally omitted from widgets per requirements
      ...ethioProgress,
      ...gregProgress,
    });

    await WidgetUpdater.updateAll();
  }
}
