import '../models/mood.dart';
import 'dart:math' as math;

/// Computes average mood per each of the last 7 days ending at [now].
/// Returns a map keyed by Spanish day abbreviations (Lun..Dom) with the
/// average mood value for that day (0.0 if no entries).
Map<String, double> computeDailyAverages({
  required DateTime now,
  required List<MoodEntry> moods,
}) {
  final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final dailyAverages = <String, double>{};

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final dayMoods = moods.where((mood) {
      final d = mood.date;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();

    final average = dayMoods.isEmpty
        ? 0.0
        : dayMoods.map((m) => m.mood.value).reduce((a, b) => a + b) /
            dayMoods.length;

    dailyAverages[dayNames[date.weekday - 1]] = average;
  }

  return dailyAverages;
}

/// Computes a representative MoodType per day for the last 7 days ending at [now].
/// Rule:
/// 1) Neutralize opposite pairs (0-5, 1-4, 2-3) by canceling min counts between each pair.
/// 2) Majority by count (>50% of remaining entries) wins.
/// 3) Otherwise, pick the category with the highest point share (count*value)
///    if its share >= 40% of the day's remaining total points.
/// 4) Otherwise, take the median of all original values and map to nearest MoodType.
Map<String, MoodType?> computeDailyRepresentativeMood({
  required DateTime now,
  required List<MoodEntry> moods,
}) {
  final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final result = <String, MoodType?>{};

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final dayMoods = moods.where((mood) {
      final d = mood.date;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();

    if (dayMoods.isEmpty) {
      result[dayNames[date.weekday - 1]] = null;
      continue;
    }

    final counts = <MoodType, int>{};
    for (final m in MoodType.values) {
      counts[m] = 0;
    }
    for (final m in dayMoods) {
      counts[m.mood] = (counts[m.mood] ?? 0) + 1;
    }

    // Effective counts after neutralizing opposite pairs
    final eff = Map<MoodType, int>.from(counts);
    void cancelPair(MoodType a, MoodType b) {
      final n = math.min(eff[a] ?? 0, eff[b] ?? 0);
      if (n > 0) {
        eff[a] = (eff[a] ?? 0) - n;
        eff[b] = (eff[b] ?? 0) - n;
      }
    }
    cancelPair(MoodType.terrible, MoodType.amazing); // 0 vs 5
    cancelPair(MoodType.bad, MoodType.great);        // 1 vs 4
    cancelPair(MoodType.okay, MoodType.good);        // 2 vs 3

    final totalEff = eff.values.fold<int>(0, (s, c) => s + c);

    // 2) Majority by count on effective distribution
    if (totalEff > 0) {
      MoodType? majorityMood;
      int maxCount = -1;
      eff.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          majorityMood = mood;
        }
      });
      if (majorityMood != null && (maxCount * 2) > totalEff) {
        result[dayNames[date.weekday - 1]] = majorityMood;
        continue;
      }
    }

    // 3) Points share dominance on effective distribution
    if (totalEff > 0) {
      final weights = <MoodType, int>{};
      int totalPoints = 0;
      eff.forEach((mood, count) {
        final w = count * mood.value;
        weights[mood] = w;
        totalPoints += w;
      });
      if (totalPoints > 0) {
        MoodType? topByShare;
        int topWeight = -1;
        eff.forEach((mood, _) {
          final w = weights[mood] ?? 0;
          if (w > topWeight) {
            topWeight = w;
            topByShare = mood;
          }
        });
        final share = topWeight / totalPoints;
        if (share >= 0.40 && topByShare != null) {
          result[dayNames[date.weekday - 1]] = topByShare;
          continue;
        }
      }
    }

    // 4) Median of original values -> nearest MoodType
    final values = <int>[];
    counts.forEach((mood, count) {
      for (int k = 0; k < count; k++) {
        values.add(mood.value);
      }
    });
    values.sort();
    double median;
    if (values.isEmpty) {
      // Fallback safety; treat as neutral
      median = 2.5;
    } else if (values.length.isOdd) {
      median = values[values.length >> 1].toDouble();
    } else {
      final mid1 = values[(values.length >> 1) - 1];
      final mid2 = values[values.length >> 1];
      median = (mid1 + mid2) / 2.0;
    }
    final nearest = median.round().clamp(0, 5);
    result[dayNames[date.weekday - 1]] = MoodType.fromValue(nearest);
  }

  return result;
}
