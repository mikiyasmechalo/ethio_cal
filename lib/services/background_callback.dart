import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:ethio_cal/constants/orthodox_day_names.dart';
import 'package:ethio_cal/services/ethiopian_date_service.dart';
import 'package:ethio_cal/services/orthodox_calendar_service.dart';
import 'package:flutter_android_widgets/flutter_android_widgets.dart';

// Called when a widget button is tapped (future use).
Future<void> backgroundCallback(Uri? uri) async {
  final date = EthiopianDateService.getFormattedDate();
  final day = EthiopianDateService.getDayOnly();

  final ethioProgress = EthiopianDateService.getEthiopianProgressData();
  final gregProgress = EthiopianDateService.getGregorianProgressData();

  final nowEt = ETDateTime.now();
  final saint = OrthodoxDayNames.getPrimarySaint(nowEt.month, nowEt.day);
  final yearName = OrthodoxCalendarService.getYearName(nowEt.year);

  await HomeWidgetData.saveAll({
    'ethiopian_date': date,
    'ethiopian_day': day,
    'orthodox_saint': saint,
    'orthodox_year': yearName,
    ...ethioProgress,
    ...gregProgress,
  });

  await WidgetUpdater.updateAll();
}
