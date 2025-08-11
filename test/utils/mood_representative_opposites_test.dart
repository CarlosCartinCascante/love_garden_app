import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/utils/mood_stats.dart';

void main() {
  MoodEntry e(DateTime base, int hour, MoodType m) => MoodEntry(
        id: '${m.value}-$hour',
        mood: m,
        date: DateTime(base.year, base.month, base.day, hour),
      );

  test('Mal vs Genial (equal counts) -> Regular/Bien median => Bien', () {
    final now = DateTime(2025, 8, 10, 12);
    final base = DateTime(now.year, now.month, now.day);
    final entries = [
      e(base, 9, MoodType.bad),
      e(base, 10, MoodType.great),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.good);
  });

  test('Regular vs Bien (equal counts) -> median 2.5 => Bien', () {
    final now = DateTime(2025, 8, 10, 12);
    final base = DateTime(now.year, now.month, now.day);
    final entries = [
      e(base, 9, MoodType.okay),
      e(base, 10, MoodType.good),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.good);
  });

  test('Terrible vs Increíble (equal counts) -> median 2.5 => Bien', () {
    final now = DateTime(2025, 8, 10, 12);
    final base = DateTime(now.year, now.month, now.day);
    final entries = [
      e(base, 9, MoodType.terrible),
      e(base, 10, MoodType.amazing),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.good);
  });
}
