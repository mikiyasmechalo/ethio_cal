import 'package:flutter_android_widgets/flutter_android_widgets.dart';

/// 1. Ethiopian Date & Day Widget (includes saint name when Orthodox features enabled)
final ethiopianDateWidgetProvider = AndroidWidget(
  info: WidgetInfo(
    widgetClassName: 'EthiopianDateWidgetProvider',
    widgetName: 'Ethiopian Date & Day',
    minWidth: 110,
    minHeight: 50,
    updateInterval: const Duration(hours: 1),
    resizeMode: WidgetResizeMode.both,
  ),
  layout: WColumn(
    backgroundColor: '#CC1E1E1E',
    padding: 14,
    gravity: WGravity.center,
    children: [
      WText(
        r'${ethiopian_date}',
        textSize: 20,
        bold: true,
        textColor: '#FFFFFF',
        gravity: WGravity.center,
      ),
      WText(
        r'${ethiopian_day}',
        textSize: 14,
        textColor: '#B3B3B3',
        gravity: WGravity.center,
      ),
      WText(
        r'${orthodox_saint}',
        textSize: 13,
        bold: true,
        textColor: '#D6A87A',
        gravity: WGravity.center,
      ),
    ],
  ),
  dataKeys: const ['ethiopian_date', 'ethiopian_day', 'orthodox_saint'],
);

/// 2. Ethiopian Day Name Widget (Weekday name + Orthodox day name)
final ethiopianDayNameWidgetProvider = AndroidWidget(
  info: WidgetInfo(
    widgetClassName: 'EthiopianDayNameWidgetProvider',
    widgetName: 'Ethiopian Day Name',
    minWidth: 50,
    minHeight: 50,
    updateInterval: const Duration(hours: 1),
    resizeMode: WidgetResizeMode.both,
  ),
  layout: WColumn(
    backgroundColor: '#CC1E1E1E',
    padding: 8,
    gravity: WGravity.center,
    children: [
      WText(
        r'${ethiopian_day}',
        textSize: 28,
        bold: true,
        textColor: '#FFFFFF',
        gravity: WGravity.center,
      ),
      WText(
        r'${orthodox_saint}',
        textSize: 12,
        bold: true,
        textColor: '#D6A87A',
        gravity: WGravity.center,
      ),
    ],
  ),
  dataKeys: const ['ethiopian_day', 'orthodox_saint'],
);

/// 3. Ethiopian Day Number & Name Widget (Day number + Weekday name + Orthodox day name)
final ethiopianDayWidgetProvider = AndroidWidget(
  info: WidgetInfo(
    widgetClassName: 'EthiopianDayWidgetProvider',
    widgetName: 'Ethiopian Day Number & Name',
    minWidth: 50,
    minHeight: 90,
    updateInterval: const Duration(hours: 1),
    resizeMode: WidgetResizeMode.both,
  ),
  layout: WColumn(
    backgroundColor: '#CC1E1E1E',
    padding: 8,
    gravity: WGravity.center,
    children: [
      WText(
        r'${ethiopian_day_number}',
        textSize: 38,
        bold: true,
        textColor: '#FFFFFF',
        gravity: WGravity.center,
      ),
      WText(
        r'${ethiopian_day}',
        textSize: 14,
        bold: true,
        textColor: '#B3B3B3',
        gravity: WGravity.center,
      ),
      WText(
        r'${orthodox_saint}',
        textSize: 11,
        bold: true,
        textColor: '#D6A87A',
        gravity: WGravity.center,
      ),
    ],
  ),
  dataKeys: const ['ethiopian_day_number', 'ethiopian_day', 'orthodox_saint'],
);

/// 4. Ethiopian Time Progress Widget
final progressEthiopianWidgetProvider = AndroidWidget(
  info: WidgetInfo(
    widgetClassName: 'ProgressEthiopianWidgetProvider',
    widgetName: 'Ethiopian Time Progress',
    minWidth: 260,
    minHeight: 140,
    updateInterval: const Duration(hours: 1),
    resizeMode: WidgetResizeMode.both,
  ),
  layout: WColumn(
    backgroundColor: '#CC1E1E1E',
    padding: 14,
    gravity: WGravity.center,
    children: [
      WText(
        r'${ethio_day_label} ${ethio_day_percent}',
        textSize: 13,
        bold: true,
        textColor: '#FFFFFF',
        gravity: WGravity.center,
      ),
    ],
  ),
  dataKeys: const [
    'ethio_day_label',
    'ethio_day_percent',
    'ethio_week_label',
    'ethio_week_percent',
    'ethio_month_label',
    'ethio_month_percent',
    'ethio_year_label',
    'ethio_year_percent',
  ],
);

/// 5. Gregorian Time Progress Widget
final progressGregorianWidgetProvider = AndroidWidget(
  info: WidgetInfo(
    widgetClassName: 'ProgressGregorianWidgetProvider',
    widgetName: 'Gregorian Time Progress',
    minWidth: 260,
    minHeight: 140,
    updateInterval: const Duration(hours: 1),
    resizeMode: WidgetResizeMode.both,
  ),
  layout: WColumn(
    backgroundColor: '#CC1E1E1E',
    padding: 14,
    gravity: WGravity.center,
    children: [
      WText(
        r'${greg_day_label} ${greg_day_percent}',
        textSize: 13,
        bold: true,
        textColor: '#FFFFFF',
        gravity: WGravity.center,
      ),
    ],
  ),
  dataKeys: const [
    'greg_day_label',
    'greg_day_percent',
    'greg_week_label',
    'greg_week_percent',
    'greg_month_label',
    'greg_month_percent',
    'greg_year_label',
    'greg_year_percent',
  ],
);

/// The consolidated list of 5 distinct widgets supported by the app
final allWidgets = [
  ethiopianDateWidgetProvider,
  ethiopianDayNameWidgetProvider,
  ethiopianDayWidgetProvider,
  progressEthiopianWidgetProvider,
  progressGregorianWidgetProvider,
];
