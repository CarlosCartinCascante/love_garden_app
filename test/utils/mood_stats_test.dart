import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/utils/mood_stats.dart';

void main() {
  group('computeDailyAverages', () {
    test('returns 0.0 for all days when no entries', () {
      final now = DateTime(2025, 8, 10, 20, 10);
      final result = computeDailyAverages(now: now, moods: []);

      // Expect seven days
      expect(result.length, 7);
      // All zeros
      expect(result.values.every((v) => v == 0.0), isTrue);
      // Keys use Spanish abbreviations
      expect(result.keys, containsAll(['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']));
    });

    test('computes average per day correctly', () {
      final now = DateTime(2025, 8, 10, 12); // Sunday
      // Helper to make entry at a specific day offset
      MoodEntry entry(int dayOffset, MoodType mood) => MoodEntry(
            id: 'id-$dayOffset-${mood.value}',
            mood: mood,
            date: DateTime(now.year, now.month, now.day).subtract(Duration(days: dayOffset)).add(const Duration(hours: 9)),
          );

      final moods = <MoodEntry>[
        // Today (Sun): two entries 4 and 2 => avg 3.0
        entry(0, MoodType.great),
        entry(0, MoodType.okay),
        // Yesterday (Sat): one entry 5 => avg 5.0
        entry(1, MoodType.amazing),
        // 2 days ago (Fri): none => 0.0
        // 3 days ago (Thu): 1 and 3 => avg 2.0
        entry(3, MoodType.bad),
        entry(3, MoodType.good),
        // 6 days ago (Mon): 0 and 1 and 5 => avg 2.0
        entry(6, MoodType.terrible),
        entry(6, MoodType.bad),
        entry(6, MoodType.amazing),
      ];

      final result = computeDailyAverages(now: now, moods: moods);

      expect(result['Dom']!.toStringAsFixed(1), '3.0'); // Sun
      expect(result['Sáb']!.toStringAsFixed(1), '5.0'); // Sat
      expect(result['Vie']!.toStringAsFixed(1), '0.0'); // Fri
      expect(result['Jue']!.toStringAsFixed(1), '2.0'); // Thu
      expect(result['Lun']!.toStringAsFixed(1), '2.0'); // Mon
    });
  });
}
