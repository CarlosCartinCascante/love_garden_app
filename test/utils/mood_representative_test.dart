import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/utils/mood_stats.dart';

void main() {
  group('computeDailyRepresentativeMood', () {
    test('majority by count wins', () {
      final now = DateTime(2025, 8, 10, 12);
      MoodEntry e(int offset, MoodType m) => MoodEntry(
            id: 'id-$offset-${m.value}-${DateTime.now().microsecondsSinceEpoch}',
            mood: m,
            date: DateTime(now.year, now.month, now.day).subtract(Duration(days: offset)).add(const Duration(hours: 9)),
          );

      final moods = <MoodEntry>[
        // Today: 10 Terrible, 5 Good -> majority Terrible
        ...List.generate(10, (_) => e(0, MoodType.terrible)),
        ...List.generate(5, (_) => e(0, MoodType.good)),
      ];

      final reps = computeDailyRepresentativeMood(now: now, moods: moods);
      expect(reps['Dom'], MoodType.terrible);
    });

    test('points share dominance applies', () {
      final now = DateTime(2025, 8, 10, 12);
      MoodEntry e(int offset, MoodType m) => MoodEntry(
            id: 'id-$offset-${m.value}-${DateTime.now().microsecondsSinceEpoch}',
            mood: m,
            date: DateTime(now.year, now.month, now.day).subtract(Duration(days: offset)).add(const Duration(hours: 9)),
          );

      final moods = <MoodEntry>[
        // Today: 10 Increíble, 10 Mal -> no majority; points share favors Increíble
        ...List.generate(10, (_) => e(0, MoodType.amazing)),
        ...List.generate(10, (_) => e(0, MoodType.bad)),
      ];

      final reps = computeDailyRepresentativeMood(now: now, moods: moods);
      expect(reps['Dom'], MoodType.amazing);
    });

    test('median fallback when no majority or dominant share', () {
      final now = DateTime(2025, 8, 10, 12);
      MoodEntry e(int offset, MoodType m) => MoodEntry(
            id: 'id-$offset-${m.value}-${DateTime.now().microsecondsSinceEpoch}',
            mood: m,
            date: DateTime(now.year, now.month, now.day).subtract(Duration(days: offset)).add(const Duration(hours: 9)),
          );

      final moods = <MoodEntry>[
        // Today: 2 of each 0..5 -> median = (2 and 3) -> 2.5 -> round 3 -> Bien
        ...List.generate(2, (_) => e(0, MoodType.terrible)),
        ...List.generate(2, (_) => e(0, MoodType.bad)),
        ...List.generate(2, (_) => e(0, MoodType.okay)),
        ...List.generate(2, (_) => e(0, MoodType.good)),
        ...List.generate(2, (_) => e(0, MoodType.great)),
        ...List.generate(2, (_) => e(0, MoodType.amazing)),
      ];

      final reps = computeDailyRepresentativeMood(now: now, moods: moods);
      expect(reps['Dom'], MoodType.good);
    });
  });
}
