import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/repositories/repositories.dart';
import '../../models/mood.dart';

/// Concrete implementation of MoodRepository using SharedPreferences.
///
/// This repository manages mood entries and provides persistent storage
/// for mood-related data.
class SharedPreferencesMoodRepository implements MoodRepository {
  static const String _moodEntriesKey = 'mood_entries';

  @override
  Future<void> addMoodEntry(MoodEntry entry) async {
    final entries = await getAllMoodEntries();
    entries.add(entry);
    await _saveMoodEntries(entries);
  }

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_moodEntriesKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MoodEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEntries = await getAllMoodEntries();
    // Use half-open interval [start, end) to avoid off-by-one overlaps
    return allEntries.where((entry) {
      final d = entry.date;
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  @override
  Future<List<MoodEntry>> getTodayMoodEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getMoodEntriesForDateRange(startOfDay, endOfDay);
  }

  @override
  Future<Map<String, int>> getTodayMoodCounts() async {
    final todayEntries = await getTodayMoodEntries();
    final counts = <String, int>{};

    for (final entry in todayEntries) {
      final moodLabel = entry.mood.label; // Use the label instead of name
      counts[moodLabel] = (counts[moodLabel] ?? 0) + 1;
    }

    return counts;
  }

  @override
  Future<void> resetTodayMoods() async {
    final allEntries = await getAllMoodEntries();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final filteredEntries = allEntries.where((entry) {
      return entry.date.isBefore(startOfDay) || entry.date.isAfter(endOfDay);
    }).toList();

    await _saveMoodEntries(filteredEntries);
  }

  @override
  Future<List<MoodEntry>> getWeeklyMoods() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final weekStart = startOfToday.subtract(
      Duration(days: now.weekday - 1),
    ); // Monday 00:00
    final weekEnd = weekStart.add(const Duration(days: 7));

    return getMoodEntriesForDateRange(weekStart, weekEnd);
  }

  @override
  Future<double> getAverageMoodScore() async {
    final allEntries = await getAllMoodEntries();

    if (allEntries.isEmpty) {
      return 0.0;
    }

    final totalScore = allEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.mood.value.toDouble(),
    );

    return totalScore / allEntries.length;
  }

  @override
  Future<void> clearAllMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodEntriesKey);
  }

  /// Private helper method to save mood entries to SharedPreferences
  Future<void> _saveMoodEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_moodEntriesKey, jsonEncode(jsonList));
  }
}
