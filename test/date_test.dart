import 'package:flutter_test/flutter_test.dart';
import 'package:ethiopian_datetime/ethiopian_datetime.dart';

void main() {
  test('ETDateTime conversions', () {
    // Gregorian to Ethiopian
    final dt = DateTime(2025, 2, 10);
    final et = dt.convertToEthiopian();
    expect(et.year, 2017);
    expect(et.month, 6); // Yekatit
    expect(et.day, 3);

    // Ethiopian to Gregorian
    final et2 = ETDateTime(2017, 6, 3);
    final dt2 = et2.convertToGregorian();
    expect(dt2.year, 2025);
    expect(dt2.month, 2);
    expect(dt2.day, 10);
  });
}
