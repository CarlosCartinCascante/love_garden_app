import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/domain/entities/user_preferences.dart';

void main() {
  test('UserPreferences stores and serializes notification times', () {
    final prefs = UserPreferences.initial();
    expect(prefs.notificationTimes['mañana'], '08:30');

    final updated = prefs.copyWith(notificationTimes: {
      'mañana': '09:00',
      'tarde': '14:00',
      'noche': '21:00',
      'madrugada': '23:45',
    });

    final json = updated.toJson();
    final restored = UserPreferences.fromJson(json);
    expect(restored.notificationTimes['mañana'], '09:00');
    expect(restored.notificationTimes['tarde'], '14:00');
    expect(restored.notificationTimes['noche'], '21:00');
    expect(restored.notificationTimes['madrugada'], '23:45');
  });
}
