import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/utils/mood_stats.dart';

void main() {
  test('1 terrible + 1 increíble -> Bien (median neutral)', () {
    final now = DateTime(2025, 8, 10, 12);
    final today = DateTime(now.year, now.month, now.day);
    final entries = [
      MoodEntry(id: 'a', mood: MoodType.terrible, date: today.add(const Duration(hours: 9))),
      MoodEntry(id: 'b', mood: MoodType.amazing, date: today.add(const Duration(hours: 10))),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.good);
  });
}
