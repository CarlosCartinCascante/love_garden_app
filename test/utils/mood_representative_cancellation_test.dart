import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/utils/mood_stats.dart';

void main() {
  MoodEntry e(DateTime base, int hour, MoodType m) => MoodEntry(
        id: '${m.value}-$hour',
        mood: m,
        date: DateTime(base.year, base.month, base.day, hour),
      );

  test('Opposites fully cancel; remaining decides', () {
    final now = DateTime(2025, 8, 10, 12);
    final base = DateTime(now.year, now.month, now.day);
    // 3 Terrible, 3 Increíble cancel -> 0; 2 Mal, 1 Genial remain -> majority Mal? No (2 of 3) -> >50% yes -> Mal
    final entries = [
      ...List.generate(3, (i) => e(base, 9 + i, MoodType.terrible)),
      ...List.generate(3, (i) => e(base, 12 + i, MoodType.amazing)),
      ...List.generate(2, (i) => e(base, 15 + i, MoodType.bad)),
      e(base, 17, MoodType.great),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.bad);
  });

  test('If all cancel out, median of originals decides', () {
    final now = DateTime(2025, 8, 10, 12);
    final base = DateTime(now.year, now.month, now.day);
    // 1 pair of each opposite -> effective zero; median over [0,1,2,3,4,5] => 2.5 -> Bien
    final entries = [
      e(base, 9, MoodType.terrible),
      e(base, 10, MoodType.amazing),
      e(base, 11, MoodType.bad),
      e(base, 12, MoodType.great),
      e(base, 13, MoodType.okay),
      e(base, 14, MoodType.good),
    ];
    final reps = computeDailyRepresentativeMood(now: now, moods: entries);
    expect(reps['Dom'], MoodType.good);
  });
}
