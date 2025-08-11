import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/utils/time_utils.dart';

void main() {
  group('TimeUtils.canonicalizeTime', () {
    test('handles 24h formats with padding and ranges', () {
      expect(TimeUtils.canonicalizeTime('8:5'), '08:05');
      expect(TimeUtils.canonicalizeTime('08:05'), '08:05');
      expect(TimeUtils.canonicalizeTime('23:59'), '23:59');
      expect(TimeUtils.canonicalizeTime('24:01'), '23:01'); // clamped hour
      expect(TimeUtils.canonicalizeTime('12:70'), '12:59'); // clamped minute
    });

    test('handles 12h AM/PM correctly', () {
      expect(TimeUtils.canonicalizeTime('12:00 AM'), '00:00');
      expect(TimeUtils.canonicalizeTime('12:00 PM'), '12:00');
      expect(TimeUtils.canonicalizeTime('1:05 PM'), '13:05');
      expect(TimeUtils.canonicalizeTime('11:59 pm'), '23:59');
      expect(TimeUtils.canonicalizeTime('07:05 am'), '07:05');
    });

    test('is resilient to noise characters and spacing', () {
      expect(TimeUtils.canonicalizeTime('  8 : 5  am '), '08:05');
      expect(TimeUtils.canonicalizeTime('8-05PM'), '20:05');
      expect(TimeUtils.canonicalizeTime('08.05'), '08:05');
      expect(TimeUtils.canonicalizeTime(''), '');
      expect(TimeUtils.canonicalizeTime(null), '');
    });
  });

  group('TimeUtils.validateHHmm', () {
    test('accepts valid HH:mm', () {
      expect(TimeUtils.validateHHmm('00:00'), isNull);
      expect(TimeUtils.validateHHmm('09:07'), isNull);
      expect(TimeUtils.validateHHmm('23:59'), isNull);
    });

    test('rejects invalid HH:mm', () {
      expect(TimeUtils.validateHHmm('24:00'), 'Formato HH:mm');
      expect(TimeUtils.validateHHmm('12:60'), 'Formato HH:mm');
      expect(TimeUtils.validateHHmm('9:5'), 'Formato HH:mm');
      expect(TimeUtils.validateHHmm('09-05'), 'Formato HH:mm');
      expect(TimeUtils.validateHHmm('0905'), 'Formato HH:mm');
      expect(TimeUtils.validateHHmm(''), 'Requerido');
      expect(TimeUtils.validateHHmm(null), 'Requerido');
    });
  });
}
